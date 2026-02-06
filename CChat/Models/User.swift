import Foundation

struct User: Codable, Equatable {
    let id: String
    var phoneNumber: String
    var displayName: String?
    var avatarURL: String?

    init(id: String, phoneNumber: String, displayName: String? = nil, avatarURL: String? = nil) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.displayName = displayName
        self.avatarURL = avatarURL
    }
}
