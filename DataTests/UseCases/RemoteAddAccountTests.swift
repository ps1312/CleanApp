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

        httpClientSpy.completeRequest(with: DomainError.unexpected)

        wait(for: [exp1, exp2], timeout: 0.1, enforceOrder: true)
    }

    func testAddCompletesWithErrorWhenRequestFails() {
        let (sut, httpClientSpy) = makeSUT()

        assertAddResult(sut, with: makeAddAccountModel(), resultsIn: .failure(.unexpected), when: {
            httpClientSpy.completeRequest(with: DomainError.unexpected)
        })
    }

    func testAddCompletesWithErrorWhenRequestSucceedsWithInvalidJSON() {
        let (sut, httpClientSpy) = makeSUT()

        assertAddResult(sut, with: makeAddAccountModel(), resultsIn: .failure(.invalidData), when: {
            httpClientSpy.completeRequest(with: makeInvalidData())
        })
    }

    func testAddCompletesWithAccountModelOnSuccess() {
        let expectedName = "specific name"
        let expectedToken = "auth token #1"
        let expectedEmail = "specific@mail.com"

        let expectedApiData = AddAccountApiResult(accessToken: expectedToken, name: expectedName).toData()!
        let expectedAccountModel = AccountModel(name: expectedName, email: expectedEmail, token: expectedToken)
        let expectedAddAccountModel = makeAddAccountModel(accountName: expectedName, accountEmail: expectedEmail)

        let (sut, httpClientSpy) = makeSUT()

        assertAddResult(sut, with: expectedAddAccountModel, resultsIn: .success(expectedAccountModel), when: {
            httpClientSpy.completeRequest(with: expectedApiData)
        })
    }

    func testAddDoesNotCompleteIfSUTHasBeenDeallocated() {
        let httpClientSpy = HTTPClientSpy()
        var sut: RemoteAddAccount? = RemoteAddAccount(url: makeURL(), httpClient: httpClientSpy)

        var capturedResult: Result<AccountModel, DomainError>? = nil
        sut?.add(addAccountModel: makeAddAccountModel()) { capturedResult = $0 }
        sut = nil

        httpClientSpy.completeRequest(with: DomainError.unexpected)

        XCTAssertNil(capturedResult)
    }

    private func assertAddResult(
        _ sut: RemoteAddAccount,
        with addAccountModel: AddAccountModel,
        resultsIn expectedResult: Result<AccountModel, DomainError>,
        when action: () -> Void
    ) {
        sut.add(addAccountModel: addAccountModel) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.failure(let receivedError), .failure(let expectedError)):
                XCTAssertEqual(receivedError, expectedError)
            case (.success(let receivedAccountModel), .success(let expectedAccountModel)):
                XCTAssertEqual(receivedAccountModel, expectedAccountModel)
            default:
                XCTFail("Expected received result to match expected result")
            }
        }

        action()
    }

    private func makeSUT(url: URL = makeURL()) -> (sut: RemoteAddAccount, httpClientSpy: HTTPClientSpy) {
        let httpClientSpy = HTTPClientSpy()
        let sut = RemoteAddAccount(url: url, httpClient: httpClientSpy)

        testMemoryLeak(instance: sut)
        testMemoryLeak(instance: httpClientSpy)

        return (sut, httpClientSpy)
    }

    private func makeAddAccountModel(accountName: String = "any name", accountEmail: String = "any@mail.com") -> AddAccountModel {
        return AddAccountModel(name: accountName, email: accountEmail, password: "12341234", passwordConfirmation: "12341234")
    }
}


