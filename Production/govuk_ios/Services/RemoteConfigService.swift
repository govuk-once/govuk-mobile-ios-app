import Foundation
import GOVKit

enum RemoteConfigKey: String {
    // remove when we have real keys
    case testKey = "test_key"
}

enum RemoteConfigFetchResult {
    case success
    case failure(Error)
}

protocol RemoteConfigServiceInterface {
    func fetch() async -> RemoteConfigFetchResult
    func activate() async
    func string(forKey key: RemoteConfigKey, defaultValue: String) -> String
    func bool(forKey key: RemoteConfigKey, defaultValue: Bool) -> Bool
    func int(forKey key: RemoteConfigKey, defaultValue: Int) -> Int
    func double(forKey key: RemoteConfigKey, defaultValue: Double) -> Double
}

class RemoteConfigService: RemoteConfigServiceInterface {
    private let remoteConfigServiceClient: RemoteConfigServiceClientInterface
    private let analyticsService: AnalyticsServiceInterface

    private var shouldUseRemoteConfig: Bool {
        return analyticsService.permissionState == .accepted
    }

    init(remoteConfigServiceClient: RemoteConfigServiceClientInterface,
         analyticsService: AnalyticsServiceInterface) {
        self.remoteConfigServiceClient = remoteConfigServiceClient
        self.analyticsService = analyticsService
    }

    func fetch() async -> RemoteConfigFetchResult {
        do {
            try await remoteConfigServiceClient.fetch()
            return .success
        } catch {
            analyticsService.track(error: error)
            return .failure(error)
        }
    }

    func activate() async {
        do {
            try await remoteConfigServiceClient.activate()
        } catch {
            analyticsService.track(error: error)
        }
    }

    func string(forKey key: RemoteConfigKey, defaultValue: String) -> String {
        guard shouldUseRemoteConfig else { return defaultValue }
        return remoteConfigServiceClient.string(forKey: key.rawValue) ?? defaultValue
    }

    func bool(forKey key: RemoteConfigKey, defaultValue: Bool) -> Bool {
        guard shouldUseRemoteConfig else { return defaultValue }
        return remoteConfigServiceClient.bool(forKey: key.rawValue) ?? defaultValue
    }

    func int(forKey key: RemoteConfigKey, defaultValue: Int) -> Int {
        guard shouldUseRemoteConfig else { return defaultValue }
        return remoteConfigServiceClient.int(forKey: key.rawValue) ?? defaultValue
    }

    func double(forKey key: RemoteConfigKey, defaultValue: Double) -> Double {
        guard shouldUseRemoteConfig else { return defaultValue }
        return remoteConfigServiceClient.double(forKey: key.rawValue) ?? defaultValue
    }
}
