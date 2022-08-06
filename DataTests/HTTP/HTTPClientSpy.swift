import Foundation
import Data

class HTTPClientSpy: HTTPPostClient {
    var requests = [URL]()
    var requestedBody: Data? = nil
    var requestsCompletions = [(Result<Data, HTTPError>) -> Void]()
    var completionObserver: (() -> Void)? = nil

    func post(to url: URL, with data: Data?, completion: @escaping (Result<Data, HTTPError>) -> Void) {
        requests.append(url)
        requestedBody = data

        requestsCompletions.append(completion)
    }

    func completeRequest(with error: HTTPError) {
        completionObserver?()
        requestsCompletions[0](.failure(error))
    }

    func completeRequest(with data: Data) {
        requestsCompletions[0](.success(data))
    }
}
