import CoreData
import Foundation

actor CoreDataDataCacheStore: DataCacheStoreProtocol {
    private enum Constants {
        static let modelName = "ScheduleCacheModel"
        static let entityName = "CacheRecord"
    }

    private let container: NSPersistentContainer
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let recordService: CoreDataCacheRecordService

    init() {
        self.init(storageType: .persistent)
    }

    static func inMemory() -> CoreDataDataCacheStore {
        CoreDataDataCacheStore(storageType: .inMemory)
    }

    private init(storageType: StorageType) {
        let model = Self.makeModel()
        container = NSPersistentContainer(name: Constants.modelName, managedObjectModel: model)
        recordService = CoreDataCacheRecordService(entityName: Constants.entityName)

        if storageType == .inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            description.shouldAddStoreAsynchronously = false
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("CoreData store load failed: \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func save(_ value: some Encodable & Sendable, for key: String) async throws {
        let payload = try encoder.encode(value)
        try await performBackgroundTask { context in
            let record = try self.recordService.upsertRecord(for: key, in: context)
            record.setValue(key, forKey: "key")
            record.setValue(payload, forKey: "payload")
            record.setValue(Date(), forKey: "updatedAt")

            if context.hasChanges {
                try context.save()
            }
        }
    }

    func load<T: Decodable & Sendable>(_: T.Type, for key: String) async throws -> T? {
        try await performBackgroundTask { context in
            guard let record = try self.recordService.fetchRecord(for: key, in: context),
                  let payload = record.value(forKey: "payload") as? Data
            else {
                return nil
            }
            return try self.decoder.decode(T.self, from: payload)
        }
    }

    private func performBackgroundTask<T>(
        _ operation: @escaping (NSManagedObjectContext) throws -> T
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            container.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                do {
                    let result = try operation(context)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = Constants.entityName
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let keyAttribute = NSAttributeDescription()
        keyAttribute.name = "key"
        keyAttribute.attributeType = .stringAttributeType
        keyAttribute.isOptional = false
        let keyIndexElement = NSFetchIndexElementDescription(
            property: keyAttribute,
            collationType: .binary
        )
        let keyIndex = NSFetchIndexDescription(
            name: "cacheRecordKeyIndex",
            elements: [keyIndexElement]
        )

        let payloadAttribute = NSAttributeDescription()
        payloadAttribute.name = "payload"
        payloadAttribute.attributeType = .binaryDataAttributeType
        payloadAttribute.allowsExternalBinaryDataStorage = true
        payloadAttribute.isOptional = false

        let updatedAtAttribute = NSAttributeDescription()
        updatedAtAttribute.name = "updatedAt"
        updatedAtAttribute.attributeType = .dateAttributeType
        updatedAtAttribute.isOptional = false

        entity.properties = [keyAttribute, payloadAttribute, updatedAtAttribute]
        entity.indexes = [keyIndex]
        entity.uniquenessConstraints = [["key"]]

        model.entities = [entity]
        return model
    }
}

typealias CoreDataScheduleCacheStore = CoreDataDataCacheStore

private enum StorageType {
    case persistent
    case inMemory
}
