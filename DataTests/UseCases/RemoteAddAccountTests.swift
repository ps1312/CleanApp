import XCTest
import Domain
import Data

class RemoteAddAccountTests: XCTestCase {
    func testAddMakesRequestWithURL() {
        let expectedURL = URL(string: "https://www.url-one.com")!
        let (sut, httpClientSpy) = makeSUT(url: expectedURL)

        sut.add(addAccountModel: makeAddAccountModel())

        XCTAssertEqual(httpClientSpy.requests, [expectedURL])
    }

    func testAddMakesRequestWithAddAccountData() {
        let (sut, httpClientSpy) = makeSUT()

        let expectedAddAccountModel = AddAccountModel(
            name: "specific name",
            email: "specific@mail.com",
            password: "43214321",
            passwordConfirmation: "43214321"
        )

        sut.add(addAccountModel: expectedAddAccountModel)

        XCTAssertEqual(httpClientSpy.requestedBody, expectedAddAccountModel.toData())
    }

    private func makeSUT(url: URL = URL(string: "https://www.any-url.com")!) -> (sut: RemoteAddAccount, httpClientSpy: HTTPClientSpy) {
        let httpClientSpy = HTTPClientSpy()
        let sut = RemoteAddAccount(url: url, httpClient: httpClientSpy)

        return (sut, httpClientSpy)
    }

    func makeAddAccountModel() -> AddAccountModel {
        return AddAccountModel(name: "any name", email: "any@mail.com", password: "12341234", passwordConfirmation: "12341234")
    }
}

class HTTPClientSpy: HTTPPostClient {
    var requests = [URL]()
    var requestedBody: Data? = nil

    func post(to url: URL, with data: Data?) {
        requests.append(url)
        requestedBody = data
    }
}
