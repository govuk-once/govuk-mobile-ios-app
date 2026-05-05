import Foundation

protocol AppLaunchServiceInterface {
    func fetch(completion: @escaping (sending AppLaunchResponse) -> Void)
}

struct AppLaunchService: AppLaunchServiceInterface {
    private let configService: AppConfigServiceInterface
    private let topicService: TopicsServiceInterface
    private let notificationService: NotificationServiceInterface
    private let remoteConfigService: RemoteConfigServiceInterface
    private let coredataService: CoreDataRepositoryInterface

    init(configService: AppConfigServiceInterface,
         topicService: TopicsServiceInterface,
         notificationService: NotificationServiceInterface,
         remoteConfigService: RemoteConfigServiceInterface,
         coredataService: CoreDataRepositoryInterface) {
        self.configService = configService
        self.topicService = topicService
        self.notificationService = notificationService
        self.remoteConfigService = remoteConfigService
        self.coredataService = coredataService
    }

    func fetch(completion: @escaping (sending AppLaunchResponse) -> Void) {
        Task {
            try await coredataService.load()
            async let configResult = fetchConfig()
            async let topicResult = fetchTopics()
            async let notificationResult = notificationService.fetchConsentAlignment()
            async let remoteConfigResult = fetchRemoteConfig()
            let response = await AppLaunchResponse(
                configResult: configResult,
                topicResult: topicResult,
                notificationConsentResult: notificationResult,
                remoteConfigFetchResult: remoteConfigResult,
                appVersionProvider: Bundle.main
            )
            DispatchQueue.main.async {
                completion(response)
            }
        }
    }

    private func fetchTopics() async -> FetchTopicsListResult {
        await withCheckedContinuation { continuation in
            topicService.fetchRemoteList(
                completion: continuation.resume
            )
        }
    }

    private func fetchConfig() async -> FetchAppConfigResult {
        await configService.fetchAppConfig()
    }

    private func fetchRemoteConfig() async -> RemoteConfigFetchResult {
        await remoteConfigService.fetch()
    }
}
