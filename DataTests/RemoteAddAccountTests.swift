import XCTest
import Domain

class RemoteAddAccount {
    private let url: URL
    private let httpClient: HTTPPostClient

    init(url: URL, httpClient: HTTPPostClient) {
        self.url = url
        self.httpClient = httpClient
    }

    func add(addAccountModel: AddAccountModel) {
        let addAccountModelData = try! JSONEncoder().encode(addAccountModel)
        httpClient.post(to: url, with: addAccountModelData)
    }
}

class RemoteAddAccountTests: XCTestCase {
    func testAddMakesRequestWithURL() {
        let anyAddAccount = AddAccountModel(
            name: "any name",
            email: "any@mail.com",
            password: "12341234",
            passwordConfirmation: "12341234"
        )
        let httpClientSpy = HTTPClientSpy()
        let expectedURL = URL(string: "https://www.url-one.com")!
        let sut = RemoteAddAccount(url: expectedURL, httpClient: httpClientSpy)

        sut.add(addAccountModel: anyAddAccount)

        XCTAssertEqual(httpClientSpy.requestedURL, expectedURL)
    }

    func testAddMakesRequestWithAddAccountData() {
        let expectedAddAccountModel = AddAccountModel(
            name: "any name",
            email: "any@mail.com",
            password: "12341234",
            passwordConfirmation: "12341234"
        )
        let expectedBody = try! JSONEncoder().encode(expectedAddAccountModel)

        let httpClientSpy = HTTPClientSpy()
        let expectedURL = URL(string: "https://www.url-one.com")!
        let sut = RemoteAddAccount(url: expectedURL, httpClient: httpClientSpy)

        sut.add(addAccountModel: expectedAddAccountModel)

        XCTAssertEqual(httpClientSpy.requestedBody, expectedBody)

    }
}

protocol HTTPPostClient {
    func post(to url: URL, with data: Data?)
}

class HTTPClientSpy: HTTPPostClient {
    var requestedURL: URL? = nil
    var requestedBody: Data? = nil

    func post(to url: URL, with data: Data?) {
        requestedURL = url
        requestedBody = data
    }
}
