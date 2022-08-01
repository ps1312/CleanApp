import Foundation

struct AddAccountModel {
    let name: String
    let email: String
    let password: String
    let passwordConfirmation: String
}

struct AccountModel {
    let name: String
    let email: String
    let token: String
}

protocol AddAccount {
    func add(addAccountModel: AddAccountModel, completion: (Result<AccountModel, Error>) -> Void)
}
