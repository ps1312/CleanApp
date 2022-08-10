import Foundation
import Domain

public final class SignupPresenter {
    public let alertView: AlertView
    public let emailValidator: EmailValidator
    public let addAccount: AddAccount

    public init(alertView: AlertView, emailValidator: EmailValidator, addAccount: AddAccount) {
        self.alertView = alertView
        self.emailValidator = emailValidator
        self.addAccount = addAccount
    }

    public func signup(viewModel: SignupViewModel) {
        if let message = validate(viewModel: viewModel) {
            alertView.showMessage(viewModel: AlertViewModel(title: "Falha na validação!", message: message))
            return
        }

        let addAccountModel = AddAccountModel(
            name: viewModel.name!,
            email: viewModel.email!,
            password: viewModel.password!,
            passwordConfirmation: viewModel.passwordConfirmation!
        )
        addAccount.add(addAccountModel: addAccountModel) { _ in }
    }

    func validate(viewModel: SignupViewModel) -> String? {
        var fieldName: String? = nil

        if (viewModel.name == nil || viewModel.name == "") {
            fieldName = "Nome"
        } else if (viewModel.email == nil || viewModel.email == "") {
            fieldName = "Email"
        } else if (viewModel.password == nil || viewModel.password == "") {
            fieldName = "Senha"
        } else if (viewModel.passwordConfirmation == nil || viewModel.passwordConfirmation == "") {
            fieldName = "Confirmação de Senha"
        }

        if let fieldName = fieldName {
            return "O campo \(fieldName) é obrigatório."
        }

        if let email = viewModel.email, !emailValidator.validate(email) {
            return "Email inválido."
        }

        if viewModel.password != viewModel.passwordConfirmation {
            return "As senhas devem ser iguais."
        }

        return nil
    }
}

public struct SignupViewModel {
    public var name: String?
    public var email: String?
    public var password: String?
    public var passwordConfirmation: String?

    public init (name: String?, email: String?, password: String?, passwordConfirmation: String?) {
        self.name = name
        self.email = email
        self.password = password
        self.passwordConfirmation = passwordConfirmation
    }
}
