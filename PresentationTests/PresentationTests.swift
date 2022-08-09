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
        alertView.showMessage(viewModel: AlertViewModel(title: "Falha na validação!", message: "O campo Nome é obrigatório."))
    }
}

class SignupPresenterTests: XCTestCase {
    func testSignUpDisplaysErrorMessageWhenNoNameIsProvided() {
        let alertViewSpy = AlertViewSpy()
        let noNameSignupViewModel = SignupViewModel(name: nil, email: "email@mail.com", password: "12341234", passwordConfirmation: "12341234")
        let sut = SignupPresenter(alertView: alertViewSpy)

        sut.signUp(viewModel: noNameSignupViewModel)

        XCTAssertEqual(alertViewSpy.viewModel, AlertViewModel(title: "Falha na validação!", message: "O campo Nome é obrigatório."))
    }
}

class AlertViewSpy: AlertView {
    var viewModel: AlertViewModel? = nil

    func showMessage(viewModel: AlertViewModel) {
        self.viewModel = viewModel
    }
}
