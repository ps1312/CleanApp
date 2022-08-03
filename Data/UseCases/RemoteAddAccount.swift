import Foundation
import Domain

public final class RemoteAddAccount {
    private let url: URL
    private let httpClient: HTTPPostClient

    public init(url: URL, httpClient: HTTPPostClient) {
        self.url = url
        self.httpClient = httpClient
    }

    public func add(addAccountModel: AddAccountModel, completion: @escaping (Result<AccountModel, DomainError>) -> Void) {
        httpClient.post(to: url, with: addAccountModel.toData()) { result in
            switch (result) {
            case .success(let receivedJSONData):
                do {
                    let addAccountApiResult = try JSONDecoder().decode(AddAccountApiResult.self, from: receivedJSONData)
                    let accountModel = AccountModel(
                        name: addAccountApiResult.name,
                        email: addAccountModel.email,
                        token: addAccountApiResult.accessToken
                    )

                    completion(.success(accountModel))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.unexpected))
            }
        }
    }
}


public struct AddAccountApiResult: Model, Decodable {
    let accessToken: String
    let name: String

    public init (accessToken: String, name: String) {
        self.accessToken = accessToken
        self.name = name
    }
}
