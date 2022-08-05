import XCTest
import Alamofire
import Data

class AlamofireAdapter: HTTPPostClient {
    let session: Session

    init(session: Session = .default) {
        self.session = session
    }

    func post(to url: URL, with data: Data?, completion: @escaping (Result<Data, HTTPError>) -> Void) {
        session
            .request(url, method: .post, parameters: convertToDict(data), encoding: JSONEncoding.default)
            .responseData { dataResponse in
                guard let response = dataResponse.response, let data = dataResponse.data else {
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

class AlamofireAdapterTests: XCTestCase {
    override func tearDown() {
        URLProtocolStub.resetStub()
    }

    func testPostMakesRequestWithCorrectParameters() {
        let expectedURL = URL(string: "https://www.specific-url.com")!

        assertRequestParameters(url: expectedURL, data: makeValidData()) { capturedRequest in
            XCTAssertEqual(capturedRequest?.url, expectedURL)
            XCTAssertEqual(capturedRequest?.method, .post)
            XCTAssertNotNil(capturedRequest?.httpBodyStream)
        }
    }

    func testPostMakesRequestWithoutBody() {
        assertRequestParameters(data: nil) { capturedRequest in
            XCTAssertNil(capturedRequest?.httpBodyStream)
        }
    }

    func testPostCompletesWithConnectionErrorOnInvalidCases() {
        assertRequestResult(error: nil, response: nil, data: nil, expectedResult: .failure(.noConnection))
        assertRequestResult(error: makeError(), response: makeHTTPURLResponse(), data: makeValidData(), expectedResult: .failure(.noConnection))

        assertRequestResult(error: makeError(), response: nil, data: nil, expectedResult: .failure(.noConnection))
        assertRequestResult(error: nil, response: makeHTTPURLResponse(), data: nil, expectedResult: .failure(.noConnection))
        assertRequestResult(error: nil, response: nil, data: makeValidData(), expectedResult: .failure(.noConnection))

        assertRequestResult(error: makeError(), response: makeHTTPURLResponse(), data: nil, expectedResult: .failure(.noConnection))
        assertRequestResult(error: makeError(), response: nil, data: makeValidData(), expectedResult: .failure(.noConnection))
    }

    func testPostCompletesWithCorrectHTTPErrors() {
        assertRequestResult(error: nil, response: makeHTTPURLResponse(statusCode: 400), data: makeValidData(), expectedResult: .failure(.badRequest))
        assertRequestResult(error: nil, response: makeHTTPURLResponse(statusCode: 401), data: makeValidData(), expectedResult: .failure(.unauthorized))
        assertRequestResult(error: nil, response: makeHTTPURLResponse(statusCode: 403), data: makeValidData(), expectedResult: .failure(.forbidden))
        assertRequestResult(error: nil, response: makeHTTPURLResponse(statusCode: 404), data: makeValidData(), expectedResult: .failure(.notFound))
        assertRequestResult(error: nil, response: makeHTTPURLResponse(statusCode: 405), data: makeValidData(), expectedResult: .failure(.badRequest))
        assertRequestResult(error: nil, response: makeHTTPURLResponse(statusCode: 499), data: makeValidData(), expectedResult: .failure(.badRequest))
        assertRequestResult(error: nil, response: makeHTTPURLResponse(statusCode: 500), data: makeValidData(), expectedResult: .failure(.serverError))
        assertRequestResult(error: nil, response: makeHTTPURLResponse(statusCode: 501), data: makeValidData(), expectedResult: .failure(.serverError))
        assertRequestResult(error: nil, response: makeHTTPURLResponse(statusCode: 599), data: makeValidData(), expectedResult: .failure(.serverError))
    }

    func testPostCompletesWithDataOnRequestSuccess() {
        let expectedData = "expected data".data(using: .utf8)!

        assertRequestResult(error: nil, response: makeHTTPURLResponse(), data: expectedData, expectedResult: .success(expectedData))
    }

    private func assertRequestResult(error: Error?, response: URLResponse?, data: Data?, expectedResult: Result<Data, HTTPError>) {
        let exp = expectation(description: "waiting for completion")

        let sut = makeSUT()

        URLProtocolStub.error = error
        URLProtocolStub.response = response
        URLProtocolStub.data = data

        sut.post(to: makeURL(), with: makeValidData()) { capturedResult in
            XCTAssertEqual(capturedResult, expectedResult)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
    }

    private func assertRequestParameters(url: URL = makeURL(), data: Data?, observeHandler: @escaping (URLRequest?) -> Void) {
        let exp = expectation(description: "waiting for request observation")

        let sut = makeSUT()

        sut.post(to: url, with: data) { _ in }

        URLProtocolStub.observeRequest = { capturedRequest in
            observeHandler(capturedRequest)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
    }

    private func makeSUT() -> AlamofireAdapter {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.protocolClasses = [URLProtocolStub.self]

        let sut = AlamofireAdapter(session: Session(configuration: sessionConfiguration))

        testMemoryLeak(instance: sut)

        return sut
    }
}

class URLProtocolStub: URLProtocol {

    static var observeRequest: ((URLRequest?) -> Void)? = nil

    static var error: Error? = nil
    static var response: URLResponse? = nil
    static var data: Data? = nil

    static func resetStub() {
        URLProtocolStub.error = nil
        URLProtocolStub.response = nil
        URLProtocolStub.data = nil
    }

    override class func canInit(with request: URLRequest) -> Bool { return true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { return request }

    override func startLoading() {
        URLProtocolStub.observeRequest?(request)

        if let response = URLProtocolStub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let data = URLProtocolStub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        if let error = URLProtocolStub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }
}

public struct AddAccountModel: Encodable {
    public let name: String
    public let email: String
    public let password: String
    public let passwordConfirmation: String

    public init (name: String, email: String, password: String, passwordConfirmation: String) {
        self.name = name
        self.email = email
        self.password = password
        self.passwordConfirmation = passwordConfirmation
    }
}
