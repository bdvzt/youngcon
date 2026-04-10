import CoreData
import Foundation

struct CoreDataCacheRecordService {
    let entityName: String

    func fetchRecord(for key: String, in context: NSManagedObjectContext) throws -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = NSPredicate(format: "key == %@", key)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    func upsertRecord(for key: String, in context: NSManagedObjectContext) throws -> NSManagedObject {
        if let existing = try fetchRecord(for: key, in: context) {
            return existing
        }
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
    }
}
