import XCTest
import Presentation
@testable import UI

class SignupViewControllerTests: XCTestCase {
    func testSignupViewControllerImplementsLoadingView() {
        XCTAssertNotNil(makeSUT() as LoadingView)
    }

    func testSignupViewControllerImplementsAlertView() {
        XCTAssertNotNil(makeSUT() as AlertView)
    }

    func makeSUT() -> SignupViewController {
        let bundle = Bundle(for: SignupViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let sut = storyboard.instantiateInitialViewController() as! SignupViewController

        return sut
    }
}


private extension SignupViewController {
    func isDisplayingLoading() -> Bool {
        return activityIndicator.isAnimating
    }
}
