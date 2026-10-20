import Foundation

extension Bundle {
    class TestClass { }
    static var current: Bundle {
        return Bundle(for: TestClass.self)
    }
}
