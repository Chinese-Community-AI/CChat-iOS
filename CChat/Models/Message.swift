import Foundation

enum MessageStatus: String, Codable {
    case sent
    case delivered
    case read
}

struct Message: Codable, Equatable {
    let id: String
    let conversationId: String
    let senderId: String
    var body: String
    let createdAt: Date
    var isOutgoing: Bool
    var status: MessageStatus

    init(
        id: String,
        conversationId: String,
        senderId: String,
        body: String,
        createdAt: Date = Date(),
        isOutgoing: Bool,
        status: MessageStatus = .sent
    ) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.body = body
        self.createdAt = createdAt
        self.isOutgoing = isOutgoing
        self.status = status
    }
}
