import Foundation

public enum HTTPError: Error {
    case noConnection
    case badRequest
    case serverError
    case unauthorized
    case forbidden
    case notFound
}
