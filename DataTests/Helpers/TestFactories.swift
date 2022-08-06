import Foundation

func makeURL() -> URL {
    return URL(string: "https://www.any-url.com")!
}

func makeInvalidData() -> Data {
    return "invalid JSON response".data(using: .utf8)!
}

func makeValidData() -> Data {
    return "{\"email\":\"example@com\"}".data(using: .utf8)!
}

func makeError() -> Error {
    return NSError(domain: "domain", code: 1)
}

func makeHTTPURLResponse(statusCode: Int = 200) -> HTTPURLResponse? {
    return HTTPURLResponse(url: makeURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)
}
