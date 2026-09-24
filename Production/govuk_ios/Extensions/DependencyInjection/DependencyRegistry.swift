import Foundation
import FactoryKit
import GovKit

public final class DependencyRegistry {
    public static let production = DependencyRegistry()
    @TaskLocal public static var testing: DependencyRegistry?
    public var analyticsService: AnalyticsServiceInterface
    = Container.shared.analyticsService.resolve()

    public init() {}
}

@propertyWrapper
public struct NativeInject<Value> {
    private let keyPath: KeyPath<DependencyRegistry, Value>

    public init(_ keyPath: KeyPath<DependencyRegistry, Value>) {
        self.keyPath = keyPath
    }

    public var wrappedValue: Value {
        let container = DependencyRegistry.testing ?? DependencyRegistry.production
        return container[keyPath: keyPath]
    }
}
