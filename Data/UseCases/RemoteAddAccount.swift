import Foundation
import Domain

public final class RemoteAddAccount {
    private let url: URL
    private let httpClient: HTTPPostClient

    public init(url: URL, httpClient: HTTPPostClient) {
        self.url = url
        self.httpClient = httpClient
    }

    public func add(addAccountModel: AddAccountModel) {
        httpClient.post(to: url, with: addAccountModel.toData())
    }
}
