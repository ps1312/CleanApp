import XCTest
import Domain
import Data

class RemoteAddAccountTests: XCTestCase {
    func testAddMakesRequestWithURL() {
        let expectedURL = URL(string: "https://www.url-one.com")!
        let (sut, httpClientSpy) = makeSUT(url: expectedURL)

        sut.add(addAccountModel: makeAddAccountModel()) { _ in }

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

        sut.add(addAccountModel: expectedAddAccountModel) { _ in }

        XCTAssertEqual(httpClientSpy.requestedBody, expectedAddAccountModel.toData())
    }

    func testAddOnlyCompletesAfterRequestCompletes() {
        let exp1 = expectation(description: "waiting for request completion")
        let exp2 = expectation(description: "waiting for SUT completion")

        let (sut, httpClientSpy) = makeSUT()

        httpClientSpy.completionObserver = { exp1.fulfill() }

        sut.add(addAccountModel: makeAddAccountModel()) { _ in exp2.fulfill() }

        httpClientSpy.completeRequest()

        wait(for: [exp1, exp2], timeout: 0.1, enforceOrder: true)
    }

    func testAddCompletesWithErrorWhenRequestFails() {
        let exp = expectation(description: "waiting for completion")
        let (sut, httpClientSpy) = makeSUT()

        sut.add(addAccountModel: makeAddAccountModel()) { error in
            XCTAssertEqual(error, DomainError.unexpected)
            exp.fulfill()
        }

        httpClientSpy.completeRequest()

        wait(for: [exp], timeout: 0.1)
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
    var requestsCompletions = [() -> Void]()
    var completionObserver: (() -> Void)? = nil

    func post(to url: URL, with data: Data?, completion: @escaping () -> Void) {
        requests.append(url)
        requestedBody = data

        requestsCompletions.append(completion)
    }

    func completeRequest(with error: DomainError = .unexpected) {
        completionObserver?()
        requestsCompletions[0]()
    }
}
