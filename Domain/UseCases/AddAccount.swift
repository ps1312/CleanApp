import Foundation

public struct AddAccountModel: Model {
    public let name: String
    public let email: String
    public let password: String
    public let passwordConfirmation: String

    public init (name: String, email: String, password: String, passwordConfirmation: String) {
        self.name = name
        self.email = email
        self.password = password
        self.passwordConfirmation = passwordConfirmation
    }
}

public protocol AddAccount {
    func add(addAccountModel: AddAccountModel, completion: @escaping (Result<AccountModel, DomainError>) -> Void)
}
