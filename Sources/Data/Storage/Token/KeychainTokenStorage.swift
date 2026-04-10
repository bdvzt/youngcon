import Foundation

final class KeychainTokenStorage: TokenStorageProtocol {
    private let store: KeyValueStoreProtocol

    init(
        service: String = KeychainConstants.tokenService,
        accessGroup: String? = nil,
        accessibility: CFString = kSecAttrAccessibleAfterFirstUnlock
    ) {
        store = KeychainStore(
            service: service,
            accessGroup: accessGroup,
            accessibility: accessibility
        )
    }

    var accessToken: String? {
        get {
            if let data = try? store.get(for: KeychainKeys.accessToken) {
                String(data: data, encoding: .utf8)
            } else {
                nil
            }
        }
        set {
            if let value = newValue {
                try? store.set(Data(value.utf8), for: KeychainKeys.accessToken)
            } else {
                try? store.delete(for: KeychainKeys.accessToken)
            }
        }
    }

    func clear() {
        try? store.delete(for: KeychainKeys.accessToken)
    }
}
