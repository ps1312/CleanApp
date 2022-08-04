import XCTest
import Alamofire

class AlamofireAdapter {
    let session: Session

    init(session: Session = .default) {
        self.session = session
    }

    func post(to url: URL) {
        session.request(url, method: .post).resume()
    }
}

class AlamofireAdapterTests: XCTestCase {

    func testPostMakesRequestWithCorrectURL() {
        let exp = expectation(description: "waiting for request observation")
        let expectedURL = URL(string: "https://www.specific-url.com")!

        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.protocolClasses = [URLProtocolStub.self]

        let sut = AlamofireAdapter(session: Session(configuration: sessionConfiguration))

        sut.post(to: expectedURL)

        URLProtocolStub.observeRequest = { capturedRequest in
            XCTAssertEqual(capturedRequest?.url, expectedURL)
            XCTAssertEqual(capturedRequest?.method, .post)
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
