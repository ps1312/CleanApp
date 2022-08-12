import UIKit
import Presentation

class SignupViewController: UIViewController {
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SignupViewController: LoadingView {
    func display(viewModel: LoadingViewModel) {
        if viewModel.isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

extension SignupViewController: AlertView {
    func showMessage(viewModel: AlertViewModel) {
        
    }
}
