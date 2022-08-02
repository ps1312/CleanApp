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
        let expectedURL = URL(string: "https://www.url-one.com")!
        let (sut, httpClientSpy) = makeSUT(url: expectedURL)

        let anyAddAccount = AddAccountModel(
            name: "any name",
            email: "any@mail.com",
            password: "12341234",
            passwordConfirmation: "12341234"
        )

        sut.add(addAccountModel: anyAddAccount)

        XCTAssertEqual(httpClientSpy.requestedURL, expectedURL)
    }

    func testAddMakesRequestWithAddAccountData() {
        let (sut, httpClientSpy) = makeSUT()

        let expectedAddAccountModel = AddAccountModel(
            name: "specific name",
            email: "specific@mail.com",
            password: "43214321",
            passwordConfirmation: "43214321"
        )
        let expectedBody = try! JSONEncoder().encode(expectedAddAccountModel)

        sut.add(addAccountModel: expectedAddAccountModel)

        XCTAssertEqual(httpClientSpy.requestedBody, expectedBody)

    }

    private func makeSUT(url: URL = URL(string: "https://www.any-url.com")!) -> (sut: RemoteAddAccount, httpClientSpy: HTTPClientSpy) {
        let httpClientSpy = HTTPClientSpy()
        let sut = RemoteAddAccount(url: url, httpClient: httpClientSpy)

        return (sut, httpClientSpy)
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
