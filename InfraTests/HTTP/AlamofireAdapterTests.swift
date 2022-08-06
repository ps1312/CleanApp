import XCTest
import Alamofire
import Data
import Infra

class AlamofireAdapterTests: XCTestCase {
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
        assertRequestResult(error: nil, response: makeHTTPURLResponse(statusCode: 600), data: makeValidData(), expectedResult: .failure(.noConnection))
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
        URLProtocolStub.resetStub()

        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.protocolClasses = [URLProtocolStub.self]

        let sut = AlamofireAdapter(session: Session(configuration: sessionConfiguration))

        testMemoryLeak(instance: sut)

        return sut
    }
}

