import XCTest
@testable import UI

class SignupViewControllerTests: XCTestCase {
    func testSignupViewControllerDoesNotDisplayLoadingOnStart() {
        let bundle = Bundle(for: SignupViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let sut = storyboard.instantiateInitialViewController() as! SignupViewController

        sut.loadViewIfNeeded()

        XCTAssertFalse(sut.isDisplayingLoading())

    }
}


private extension SignupViewController {
    func isDisplayingLoading() -> Bool {
        return activityIndicator.isAnimating
    }
}
