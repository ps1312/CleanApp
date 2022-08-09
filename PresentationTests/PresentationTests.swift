import XCTest

struct AlertViewModel: Equatable {
    let title: String
    let message: String
}

protocol AlertView {
    func showMessage(viewModel: AlertViewModel)
}

struct SignupViewModel {
    var name: String?
    var email: String?
    var password: String?
    var passwordConfirmation: String?
}

class SignupPresenter {
    let alertView: AlertView

    init(alertView: AlertView) {
        self.alertView = alertView
    }

    func signUp(viewModel: SignupViewModel) {
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

        alertView.showMessage(viewModel: AlertViewModel(title: "Falha na validação!", message: "O campo \(fieldName!) é obrigatório."))
    }
}

class SignupPresenterTests: XCTestCase {
    func testSignUpDisplaysRequiredErrorWhenFieldsAreNil() {
        assertRequiredValidationError(
            signupViewModel: SignupViewModel(name: nil, email: "email@mail.com", password: "12341234", passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Nome é obrigatório.")
        )

        assertRequiredValidationError(
            signupViewModel: SignupViewModel(name: "name", email: nil, password: "12341234", passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Email é obrigatório.")
        )

        assertRequiredValidationError(
            signupViewModel: SignupViewModel(name: "name", email: "email@mail.com", password: nil, passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Senha é obrigatório.")
        )

        assertRequiredValidationError(
            signupViewModel: SignupViewModel(name: "name", email: "email@mail.com", password: "12341234", passwordConfirmation: nil),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Confirmação de Senha é obrigatório.")
        )
    }

    func testSignUpDisplaysRequiredErrorWhenFieldsAreEmpty() {
        assertRequiredValidationError(
            signupViewModel: SignupViewModel(name: "", email: "email@mail.com", password: "12341234", passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Nome é obrigatório.")
        )

        assertRequiredValidationError(
            signupViewModel: SignupViewModel(name: "name", email: "", password: "12341234", passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Email é obrigatório.")
        )

        assertRequiredValidationError(
            signupViewModel: SignupViewModel(name: "name", email: "email@mail.com", password: "", passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Senha é obrigatório.")
        )

        assertRequiredValidationError(
            signupViewModel: SignupViewModel(name: "name", email: "email@mail.com", password: "12341234", passwordConfirmation: ""),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Confirmação de Senha é obrigatório.")
        )
    }

    func assertRequiredValidationError(signupViewModel: SignupViewModel, expectedAlertViewModel: AlertViewModel) {
        let alertViewSpy = AlertViewSpy()
        let sut = SignupPresenter(alertView: alertViewSpy)

        sut.signUp(viewModel: signupViewModel)

        XCTAssertEqual(alertViewSpy.viewModel, expectedAlertViewModel)
    }
}

class AlertViewSpy: AlertView {
    var viewModel: AlertViewModel? = nil

    func showMessage(viewModel: AlertViewModel) {
        self.viewModel = viewModel
    }
}
