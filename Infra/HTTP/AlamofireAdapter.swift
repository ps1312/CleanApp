import Foundation
import Data
import Alamofire

public class AlamofireAdapter: HTTPPostClient {
    let session: Session

    public init(session: Session = .default) {
        self.session = session
    }

    public func post(to url: URL, with data: Data?, completion: @escaping (Result<Data, HTTPError>) -> Void) {
        session
            .request(url, method: .post, parameters: convertToDict(data), encoding: JSONEncoding.default)
            .responseData { dataResponse in
                guard let response = dataResponse.response else {
                    completion(.failure(.noConnection))
                    return
                }

                guard let data = dataResponse.data else {
                    if (response.statusCode == 204) {
                        completion(.success(Data()))
                        return
                    }

                    completion(.failure(.noConnection))
                    return
                }

                switch (response.statusCode) {
                case 200:
                    completion(.success(data))
                case 401:
                    completion(.failure(.unauthorized))
                case 403:
                    completion(.failure(.forbidden))
                case 404:
                    completion(.failure(.notFound))
                case 400...499:
                    completion(.failure(.badRequest))
                case 500...599:
                    completion(.failure(.serverError))
                default:
                    completion(.failure(.noConnection))
                }
            }.resume()
    }

    private func convertToDict(_ data: Data?) -> [String: Any]? {
        return data == nil ? nil : try? JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as? [String: Any]
    }
}
