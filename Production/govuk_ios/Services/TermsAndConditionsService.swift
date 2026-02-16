import Foundation
import GovKit

protocol TermsAndConditionsServiceInterface {
    var termsAcceptanceIsValid: Bool { get }
    var termsAndContitionsURL: URL { get }
    func saveAcceptanceDate()
    func resetAcceptanceDate()
}

struct TermsAndConditionsService: TermsAndConditionsServiceInterface {
    private let appConfigService: AppConfigServiceInterface
    private let userDefaultsService: UserDefaultsServiceInterface

    init(
        appConfigService: AppConfigServiceInterface,
        userDefaultsService: UserDefaultsServiceInterface
    ) {
        self.appConfigService = appConfigService
        self.userDefaultsService = userDefaultsService
    }

    var termsAcceptanceIsValid: Bool {
        guard let acceptanceDate = userDefaultsService.value(
            forKey: .termsAndConditionsAcceptanceDate
        ) as? Date else {
            return false
        }
        return acceptanceDate > appConfigService.termsAndConditions?.lastUpdated ?? .now
    }

    var termsAndContitionsURL: URL {
        appConfigService.termsAndConditions?.url ?? Constants.API.termsAndConditionsUrl
    }

    func saveAcceptanceDate() {
        userDefaultsService.set(
            Date.now,
            forKey: .termsAndConditionsAcceptanceDate
        )
    }

    func resetAcceptanceDate() {
        userDefaultsService.removeObject(
            forKey: .termsAndConditionsAcceptanceDate
        )
    }
}
