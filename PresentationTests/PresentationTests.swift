import XCTest
import Presentation

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
