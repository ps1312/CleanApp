import Foundation
import Domain

public protocol HTTPPostClient {
    func post(to url: URL, with data: Data?, completion: @escaping () -> Void)
}
