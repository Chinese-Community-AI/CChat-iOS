import Foundation

struct Conversation: Codable, Equatable {
    let id: String
    var participantIds: [String]
    var lastMessageAt: Date
    var lastMessagePreview: String?

    init(id: String, participantIds: [String], lastMessageAt: Date = Date(), lastMessagePreview: String? = nil) {
        self.id = id
        self.participantIds = participantIds
        self.lastMessageAt = lastMessageAt
        self.lastMessagePreview = lastMessagePreview
    }
}
