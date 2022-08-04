import XCTest
import Alamofire

class AlamofireAdapter {
    let session: Session

    init(session: Session = .default) {
        self.session = session
    }

    func post(to url: URL, with data: Data?) {
        let json = data == nil ? nil : try? JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as? [String: Any]
        session.request(url, method: .post, parameters: json, encoding: JSONEncoding.default).resume()
    }
}

class AlamofireAdapterTests: XCTestCase {

    func testPostMakesRequestWithCorrectParameters() {
        let exp = expectation(description: "waiting for request observation")
        let expectedURL = URL(string: "https://www.specific-url.com")!

        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.protocolClasses = [URLProtocolStub.self]

        let sut = AlamofireAdapter(session: Session(configuration: sessionConfiguration))

        sut.post(to: expectedURL, with: makeValidData())

        URLProtocolStub.observeRequest = { capturedRequest in
            XCTAssertEqual(capturedRequest?.url, expectedURL)
            XCTAssertEqual(capturedRequest?.method, .post)
            XCTAssertNotNil(capturedRequest?.httpBodyStream)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
    }

    func testPostMakesRequestWithoutBody() {
        let exp = expectation(description: "waiting for request observation")
        let expectedURL = URL(string: "https://www.specific-url.com")!

        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.protocolClasses = [URLProtocolStub.self]

        let sut = AlamofireAdapter(session: Session(configuration: sessionConfiguration))

        sut.post(to: expectedURL, with: nil)

        URLProtocolStub.observeRequest = { capturedRequest in
            XCTAssertNil(capturedRequest?.httpBodyStream)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
    }

}

class URLProtocolStub: URLProtocol {

    static var observeRequest: ((URLRequest?) -> Void)? = nil

    override class func canInit(with request: URLRequest) -> Bool { return true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { return request }

    override func startLoading() {
        URLProtocolStub.observeRequest?(request)
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
