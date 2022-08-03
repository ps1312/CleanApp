import Foundation

public struct AccountModel: Model {
    let name: String
    let email: String
    let token: String

    public init(name: String, email: String, token: String) {
        self.name = name
        self.email = email
        self.token = token
    }
}
