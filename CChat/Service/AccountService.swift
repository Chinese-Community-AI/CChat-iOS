import Foundation

enum AccountError: Error {
    case notRegistered
    case saveFailed
}

final class AccountService {
    static let shared = AccountService()
    
    private let storage = StorageService.shared
    
    var currentUser: User? {
        try? storage.getCurrentUser()
    }
    
    var isRegistered: Bool {
        currentUser != nil
    }
    
    private init() {}
    
    func register(phoneNumber: String, displayName: String) throws {
        let user = User(
            id: UUID().uuidString,
            phoneNumber: phoneNumber,
            displayName: displayName
        )
        try storage.saveCurrentUser(user)
    }
    
    func updateProfile(displayName: String?) throws {
        guard var user = currentUser else { throw AccountError.notRegistered }
        user.displayName = displayName
        try storage.saveCurrentUser(user)
    }
    
    func logout() throws {
        try storage.saveCurrentUser(nil)
    }
}
