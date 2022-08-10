import Foundation

public final class SignupPresenter {
    public let alertView: AlertView
    public let emailValidator: EmailValidator

    public init(alertView: AlertView, emailValidator: EmailValidator) {
        self.alertView = alertView
        self.emailValidator = emailValidator
    }

    public func signUp(viewModel: SignupViewModel) {
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
            alertView.showMessage(viewModel: AlertViewModel(title: "Falha na validação!", message: "O campo \(fieldName) é obrigatório."))
            return
        }

        if let email = viewModel.email, !emailValidator.validate(email) {
            alertView.showMessage(viewModel: AlertViewModel(title: "Falha na validação!", message: "Email inválido."))
            return
        }
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
