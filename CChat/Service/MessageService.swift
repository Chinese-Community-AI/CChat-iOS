import Foundation

final class MessageService {
    static let shared = MessageService()
    
    private let storage = StorageService.shared
    private let account = AccountService.shared
    
    private init() {}
    
    func sendMessage(to conversationId: String, body: String) throws -> Message {
        guard let user = account.currentUser else { throw AccountError.notRegistered }
        let message = Message(
            id: UUID().uuidString,
            conversationId: conversationId,
            senderId: user.id,
            body: body,
            isOutgoing: true
        )
        try storage.saveMessage(message)
        return message
    }
    
    func getMessages(for conversationId: String) throws -> [Message] {
        try storage.getMessages(conversationId: conversationId)
    }
    
    func getOrCreateConversation(with contact: Contact) throws -> Conversation {
        guard let user = account.currentUser else { throw AccountError.notRegistered }
        let participantIds = [user.id, contact.userId ?? contact.id].sorted()
        let convId = "conv_\(participantIds.joined(separator: "_"))"
        
        let existing = try storage.getConversations().first { $0.id == convId }
        if let conv = existing {
            return conv
        }
        
        let conv = Conversation(id: convId, participantIds: participantIds)
        try storage.saveConversation(conv)
        return conv
    }
    
    func addContact(phoneNumber: String, displayName: String?) throws -> Contact {
        let contact = Contact(
            id: UUID().uuidString,
            phoneNumber: phoneNumber,
            displayName: displayName ?? phoneNumber
        )
        try storage.saveContact(contact)
        return contact
    }
    
    func getContacts() throws -> [Contact] {
        try storage.getContacts()
    }
    
    func getConversations() throws -> [Conversation] {
        try storage.getConversations()
    }
}
