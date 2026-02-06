import Foundation

enum StorageError: Error {
    case saveFailed
    case loadFailed
    case encodingFailed
    case decodingFailed
}

final class StorageService {
    static let shared = StorageService()
    
    private let fileManager = FileManager.default
    private let crypto = CryptographyService.shared
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private var storageURL: URL {
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("cchat_data.enc", isDirectory: false)
    }
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    struct StorageData: Codable {
        var user: User?
        var contacts: [Contact]
        var conversations: [Conversation]
        var messages: [Message]
        
        static var empty: StorageData {
            StorageData(user: nil, contacts: [], conversations: [], messages: [])
        }
    }
    
    private func loadRaw() throws -> StorageData {
        guard fileManager.fileExists(atPath: storageURL.path) else {
            return .empty
        }
        let encrypted = try Data(contentsOf: storageURL)
        let decrypted = try crypto.decrypt(encrypted)
        return try decoder.decode(StorageData.self, from: decrypted)
    }
    
    private func save(_ data: StorageData) throws {
        let encoded = try encoder.encode(data)
        let encrypted = try crypto.encrypt(encoded)
        try encrypted.write(to: storageURL)
    }
    
    func getCurrentUser() throws -> User? {
        try loadRaw().user
    }
    
    func saveCurrentUser(_ user: User?) throws {
        var data = try loadRaw()
        data.user = user
        try save(data)
    }
    
    func getContacts() throws -> [Contact] {
        try loadRaw().contacts
    }
    
    func saveContact(_ contact: Contact) throws {
        var data = try loadRaw()
        if let idx = data.contacts.firstIndex(where: { $0.id == contact.id }) {
            data.contacts[idx] = contact
        } else {
            data.contacts.append(contact)
        }
        try save(data)
    }
    
    func getConversations() throws -> [Conversation] {
        try loadRaw().conversations.sorted { $0.lastMessageAt > $1.lastMessageAt }
    }
    
    func saveConversation(_ conversation: Conversation) throws {
        var data = try loadRaw()
        if let idx = data.conversations.firstIndex(where: { $0.id == conversation.id }) {
            data.conversations[idx] = conversation
        } else {
            data.conversations.append(conversation)
        }
        try save(data)
    }
    
    func getMessages(conversationId: String) throws -> [Message] {
        try loadRaw().messages
            .filter { $0.conversationId == conversationId }
            .sorted { $0.createdAt < $1.createdAt }
    }
    
    func saveMessage(_ message: Message) throws {
        var data = try loadRaw()
        if let idx = data.messages.firstIndex(where: { $0.id == message.id }) {
            data.messages[idx] = message
        } else {
            data.messages.append(message)
        }
        if let idx = data.conversations.firstIndex(where: { $0.id == message.conversationId }) {
            data.conversations[idx].lastMessageAt = message.createdAt
            data.conversations[idx].lastMessagePreview = String(message.body.prefix(50))
        }
        try save(data)
    }
}
