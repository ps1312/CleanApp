import XCTest

class RemoteAddAccount {
    private let url: URL
    private let httpClient: HTTPPostClient

    init(url: URL, httpClient: HTTPPostClient) {
        self.url = url
        self.httpClient = httpClient
    }

    func add() {
        httpClient.post(to: url)
    }
}

class RemoteAddAccountTests: XCTestCase {
    func testAddMakesRequestWithURL() {
        let httpClientSpy = HTTPClientSpy()
        let expectedURL = URL(string: "https://www.url-one.com")!
        let sut = RemoteAddAccount(url: expectedURL, httpClient: httpClientSpy)

        sut.add()

        XCTAssertEqual(httpClientSpy.requestedURL, expectedURL)
    }
}

protocol HTTPPostClient {
    func post(to url: URL)
}

class HTTPClientSpy: HTTPPostClient {
    var requestedURL: URL? = nil

    func post(to url: URL) {
        requestedURL = url
    }
}
