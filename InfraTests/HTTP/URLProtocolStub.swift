import Foundation

class URLProtocolStub: URLProtocol {

    static var observeRequest: ((URLRequest?) -> Void)? = nil

    static var error: Error? = nil
    static var response: URLResponse? = nil
    static var data: Data? = nil

    static func resetStub() {
        URLProtocolStub.error = nil
        URLProtocolStub.response = nil
        URLProtocolStub.data = nil
    }

    override class func canInit(with request: URLRequest) -> Bool { return true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { return request }

    override func startLoading() {
        URLProtocolStub.observeRequest?(request)

        if let response = URLProtocolStub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let data = URLProtocolStub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        if let error = URLProtocolStub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }
}
