import Foundation

func makeURL() -> URL {
    return URL(string: "https://www.any-url.com")!
}

func makeInvalidData() -> Data {
    return "invalid JSON response".data(using: .utf8)!
}
