import Foundation

public struct LoadingViewModel: Equatable {
    public let isLoading: Bool

    public init (isLoading: Bool) {
        self.isLoading = isLoading
    }
}

public protocol LoadingView {
    func display(viewModel: LoadingViewModel)
}
