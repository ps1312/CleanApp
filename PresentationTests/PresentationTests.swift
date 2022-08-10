import XCTest
import Presentation
@testable import Domain

class SignupPresenterTests: XCTestCase {
    func testSignupDisplaysInvalidEmailError() {
        let alertViewSpy = AlertViewSpy()
        let emailValidatorSpy = EmailValidatorSpy()
        let sut = makeSUT(alertViewSpy: alertViewSpy, emailValidatorSpy: emailValidatorSpy)

        emailValidatorSpy.simulate(validation: false)

        sut.signup(viewModel: makeSignupViewModel())

        XCTAssertEqual(alertViewSpy.viewModel, AlertViewModel(title: "Falha na validação!", message: "Email inválido."))
    }

    func testSignupDisplaysPasswordsDontMatchError() {
        assertAlertViewModel(
            signupViewModel: makeSignupViewModel(password: "12341234", passwordConfirmation: "senhasenha"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "As senhas devem ser iguais.")
        )
    }

    func testSignupDisplaysRequiredErrorWhenFieldsAreNil() {
        assertAlertViewModel(
            signupViewModel: SignupViewModel(name: nil, email: "email@mail.com", password: "12341234", passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Nome é obrigatório.")
        )

        assertAlertViewModel(
            signupViewModel: SignupViewModel(name: "name", email: nil, password: "12341234", passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Email é obrigatório.")
        )

        assertAlertViewModel(
            signupViewModel: SignupViewModel(name: "name", email: "email@mail.com", password: nil, passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Senha é obrigatório.")
        )

        assertAlertViewModel(
            signupViewModel: SignupViewModel(name: "name", email: "email@mail.com", password: "12341234", passwordConfirmation: nil),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Confirmação de Senha é obrigatório.")
        )
    }

    func testSignupDisplaysRequiredErrorWhenFieldsAreEmpty() {
        assertAlertViewModel(
            signupViewModel: SignupViewModel(name: "", email: "email@mail.com", password: "12341234", passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Nome é obrigatório.")
        )

        assertAlertViewModel(
            signupViewModel: SignupViewModel(name: "name", email: "", password: "12341234", passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Email é obrigatório.")
        )

        assertAlertViewModel(
            signupViewModel: SignupViewModel(name: "name", email: "email@mail.com", password: "", passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Senha é obrigatório.")
        )

        assertAlertViewModel(
            signupViewModel: SignupViewModel(name: "name", email: "email@mail.com", password: "12341234", passwordConfirmation: ""),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Confirmação de Senha é obrigatório.")
        )
    }

    func testSignupExecutesAddAccountUsecaseOnValidSubmission() {
        let addAccountSpy = AddAccountSpy()
        let sut = makeSUT(addAccountSpy: addAccountSpy)

        sut.signup(viewModel: makeSignupViewModel())

        XCTAssertEqual(addAccountSpy.calls, 1)
    }

    func makeSUT(
        alertViewSpy: AlertViewSpy = AlertViewSpy(),
        emailValidatorSpy: EmailValidatorSpy = EmailValidatorSpy(),
        addAccountSpy: AddAccountSpy = AddAccountSpy()
    ) -> SignupPresenter {
        let sut = SignupPresenter(alertView: alertViewSpy, emailValidator: emailValidatorSpy, addAccount: addAccountSpy)

        return sut
    }

    func assertAlertViewModel(signupViewModel: SignupViewModel, expectedAlertViewModel: AlertViewModel) {
        let alertViewSpy = AlertViewSpy()
        let sut = makeSUT(alertViewSpy: alertViewSpy)

        sut.signup(viewModel: signupViewModel)

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

// 2.0

class AddAccountSpy: AddAccount {
    var calls = 0

    func add(addAccountModel: AddAccountModel, completion: (Result<AccountModel, Error>) -> Void) {
        self.calls += 1
    }
}
