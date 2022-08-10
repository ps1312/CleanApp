import XCTest
import Presentation

class SignupPresenterTests: XCTestCase {
    func testSignUpDisplaysInvalidEmailError() {
        let invalidEmailSignupViewModel = makeSignupViewModel(email: "invalid_email")
        let (sut, alertViewSpy, emailValidatorSpy) = makeSUT()

        emailValidatorSpy.simulate(validation: false)

        sut.signUp(viewModel: invalidEmailSignupViewModel)

        XCTAssertEqual(alertViewSpy.viewModel, AlertViewModel(title: "Falha na validação!", message: "Email inválido."))
    }

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

    func makeSUT() -> (SignupPresenter, AlertViewSpy, EmailValidatorSpy) {
        let emailValidatorSpy = EmailValidatorSpy()
        let alertViewSpy = AlertViewSpy()
        let sut = SignupPresenter(alertView: alertViewSpy, emailValidator: emailValidatorSpy)

        return (sut, alertViewSpy, emailValidatorSpy)
    }

    func assertRequiredValidationError(signupViewModel: SignupViewModel, expectedAlertViewModel: AlertViewModel) {
        let (sut, alertViewSpy, _) = makeSUT()

        sut.signUp(viewModel: signupViewModel)

        XCTAssertEqual(alertViewSpy.viewModel, expectedAlertViewModel)
    }

    func makeSignupViewModel(name: String? = "name", email: String? = "email@mail.com", password: String? = "12341234", passwordConfirmation: String? = "12341234") -> SignupViewModel {
        return SignupViewModel(name: name, email: email, password: password, passwordConfirmation: passwordConfirmation)
    }
}

class AlertViewSpy: AlertView {
    var viewModel: AlertViewModel? = nil

    func showMessage(viewModel: AlertViewModel) {
        self.viewModel = viewModel
    }
}

class EmailValidatorSpy: EmailValidator {
    var isEmailValid = true

    func simulate(validation: Bool) {
        isEmailValid = validation
    }

    func validate(_ email: String) -> Bool {
        return isEmailValid
    }
}
