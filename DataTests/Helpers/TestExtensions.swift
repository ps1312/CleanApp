import Foundation
import XCTest

extension XCTestCase {
    func testMemoryLeak(instance: AnyObject) {
        addTeardownBlock { [weak instance] in XCTAssertNil(instance) }
    }
}
