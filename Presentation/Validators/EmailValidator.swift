import Foundation

public protocol EmailValidator {
    func validate(email: String) -> Bool
}
