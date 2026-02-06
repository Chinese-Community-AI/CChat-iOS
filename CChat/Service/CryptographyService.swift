import Foundation
import CryptoKit

enum CryptographyError: Error {
    case encryptionFailed
    case decryptionFailed
    case keyGenerationFailed
}

final class CryptographyService {
    static let shared = CryptographyService()
    
    private let keyTag = "com.cchat.encryption.key"
    
    private init() {}
    
    func encrypt(_ data: Data) throws -> Data {
        let key = try getOrCreateKey()
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else { throw CryptographyError.encryptionFailed }
        return combined
    }
    
    func decrypt(_ data: Data) throws -> Data {
        let key = try getOrCreateKey()
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }
    
    func encryptString(_ string: String) throws -> Data {
        guard let data = string.data(using: .utf8) else { throw CryptographyError.encryptionFailed }
        return try encrypt(data)
    }
    
    func decryptString(_ data: Data) throws -> String {
        let decrypted = try decrypt(data)
        guard let string = String(data: decrypted, encoding: .utf8) else { throw CryptographyError.decryptionFailed }
        return string
    }
    
    private func getOrCreateKey() throws -> SymmetricKey {
        if let existing = loadKey() {
            return existing
        }
        let key = SymmetricKey(size: .bits256)
        try saveKey(key)
        return key
    }
    
    private func saveKey(_ key: SymmetricKey) throws {
        let keyData = key.withUnsafeBytes { Data($0) }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyTag,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw CryptographyError.keyGenerationFailed }
    }
    
    private func loadKey() -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyTag,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let keyData = result as? Data else { return nil }
        return SymmetricKey(data: keyData)
    }
}
