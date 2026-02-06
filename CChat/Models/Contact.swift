import Foundation

struct Contact: Codable, Equatable {
    let id: String
    var phoneNumber: String
    var displayName: String?
    var userId: String?

    init(id: String, phoneNumber: String, displayName: String? = nil, userId: String? = nil) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.displayName = displayName
        self.userId = userId
    }
}
