import Foundation

public protocol EmailValidator {
    func validate(_ email: String) -> Bool
}
