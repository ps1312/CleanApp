import Foundation

public struct AlertViewModel: Equatable {
    public let title: String
    public let message: String

    public init (title: String, message: String) {
        self.title = title
        self.message = message
    }
}

public protocol AlertView {
    func showMessage(viewModel: AlertViewModel)
}
