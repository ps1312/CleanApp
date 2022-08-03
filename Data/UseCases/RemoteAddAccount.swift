import Foundation
import Domain

public final class RemoteAddAccount {
    private let url: URL
    private let httpClient: HTTPPostClient

    public init(url: URL, httpClient: HTTPPostClient) {
        self.url = url
        self.httpClient = httpClient
    }

    public func add(addAccountModel: AddAccountModel, completion: @escaping (DomainError) -> Void) {
        httpClient.post(to: url, with: addAccountModel.toData()) { result in
            switch (result) {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.unexpected)
            }
        }
    }
}
