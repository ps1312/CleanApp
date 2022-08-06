import Foundation

public struct AccountModel: Model {
    public let name: String
    public let email: String
    public let token: String

    public init(name: String, email: String, token: String) {
        self.name = name
        self.email = email
        self.token = token
    }
}
