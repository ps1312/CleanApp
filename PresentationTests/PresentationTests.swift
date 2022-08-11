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
        assertAlertView(
            signupViewModel: makeSignupViewModel(password: "12341234", passwordConfirmation: "senhasenha"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "As senhas devem ser iguais.")
        )
    }

    func testSignupDisplaysRequiredErrorWhenFieldsAreNil() {
        assertAlertView(
            signupViewModel: SignupViewModel(name: nil, email: "email@mail.com", password: "12341234", passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Nome é obrigatório.")
        )

        assertAlertView(
            signupViewModel: SignupViewModel(name: "name", email: nil, password: "12341234", passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Email é obrigatório.")
        )

        assertAlertView(
            signupViewModel: SignupViewModel(name: "name", email: "email@mail.com", password: nil, passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Senha é obrigatório.")
        )

        assertAlertView(
            signupViewModel: SignupViewModel(name: "name", email: "email@mail.com", password: "12341234", passwordConfirmation: nil),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Confirmação de Senha é obrigatório.")
        )
    }

    func testSignupDisplaysRequiredErrorWhenFieldsAreEmpty() {
        assertAlertView(
            signupViewModel: SignupViewModel(name: "", email: "email@mail.com", password: "12341234", passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Nome é obrigatório.")
        )

        assertAlertView(
            signupViewModel: SignupViewModel(name: "name", email: "", password: "12341234", passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Email é obrigatório.")
        )

        assertAlertView(
            signupViewModel: SignupViewModel(name: "name", email: "email@mail.com", password: "", passwordConfirmation: "12341234"),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Senha é obrigatório.")
        )

        assertAlertView(
            signupViewModel: SignupViewModel(name: "name", email: "email@mail.com", password: "12341234", passwordConfirmation: ""),
            expectedAlertViewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Confirmação de Senha é obrigatório.")
        )
    }

    func testSignupExecutesAddAccountUsecaseOnValidSubmission() {
        let expectedName = "a name"
        let expectedEmail = "email@test.com"
        let expectedPwd = "test@123"
        let expectedPwdConfirmation = "test@123"
        let addAccountSpy = AddAccountSpy()
        let sut = makeSUT(addAccountSpy: addAccountSpy)

        sut.signup(viewModel: makeSignupViewModel(name: expectedName, email: expectedEmail, password: expectedPwd, passwordConfirmation: expectedPwdConfirmation))

        let expectedAddAccountModel = AddAccountModel(name: expectedName, email: expectedEmail, password: expectedPwd, passwordConfirmation: expectedPwdConfirmation)
        XCTAssertEqual(addAccountSpy.calls, [expectedAddAccountModel])
    }

    func testSignupDisplaysErrorOnSubmissionFail() {
        let addAccountSpy = AddAccountSpy()
        let alertViewSpy = AlertViewSpy()
        let sut = makeSUT(alertViewSpy: alertViewSpy, addAccountSpy: addAccountSpy)

        sut.signup(viewModel: makeSignupViewModel())

        addAccountSpy.completeWithError()

        XCTAssertEqual(alertViewSpy.viewModel, AlertViewModel(title: "Falha no cadastro!", message: "Ocorreu um erro ao fazer o cadastro."))
    }

    func testSignupDisplaysLoadingWhileSubmitting() {
        let addAccountSpy = AddAccountSpy()
        let loadingViewSpy = LoadingViewSpy()
        let sut = makeSUT(addAccountSpy: addAccountSpy, loadingViewSpy: loadingViewSpy)

        sut.signup(viewModel: makeSignupViewModel())

        XCTAssertEqual(loadingViewSpy.viewModel, LoadingViewModel(isLoading: true))
        addAccountSpy.completeWithError()
        XCTAssertEqual(loadingViewSpy.viewModel, LoadingViewModel( isLoading: false))

    }

    func makeSUT(
        alertViewSpy: AlertViewSpy = AlertViewSpy(),
        emailValidatorSpy: EmailValidatorSpy = EmailValidatorSpy(),
        addAccountSpy: AddAccountSpy = AddAccountSpy(),
        loadingViewSpy: LoadingViewSpy = LoadingViewSpy()
    ) -> SignupPresenter {
        let sut = SignupPresenter(alertView: alertViewSpy, loadingView: loadingViewSpy, emailValidator: emailValidatorSpy, addAccount: addAccountSpy)

        testMemoryLeak(instance: sut)
        testMemoryLeak(instance: alertViewSpy)
        testMemoryLeak(instance: loadingViewSpy)
        testMemoryLeak(instance: emailValidatorSpy)
        testMemoryLeak(instance: addAccountSpy)

        return sut
    }

    func assertAlertView(signupViewModel: SignupViewModel, expectedAlertViewModel: AlertViewModel) {
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

class AddAccountSpy: AddAccount {
    var calls = [AddAccountModel]()
    var completions = [(Result<AccountModel, DomainError>) -> Void]()

    func add(addAccountModel: AddAccountModel, completion: @escaping (Result<AccountModel, DomainError>) -> Void) {
        calls.append(addAccountModel)
        completions.append(completion)
    }

    func completeWithError() {
        completions[0](.failure(.unexpected))
    }
}

class LoadingViewSpy: LoadingView {
    var viewModel: LoadingViewModel? = nil

    func display(viewModel: LoadingViewModel) {
        self.viewModel = viewModel
    }
}
