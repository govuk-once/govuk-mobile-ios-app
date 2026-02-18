import Foundation
import Testing

@testable import govuk_ios

@Suite
struct TermsAndConditionsServiceTests {

    @Test
    func termsAcceptanceIsValid_when_lastUpdateEarlierThanAcceptance() {
        let mockAppConfigService = MockAppConfigService()
        let mockUserDefaultService = MockUserDefaultsService()
        let configLastUpdated = Date.now.addingTimeInterval(-600)
        let acceptanceDate = Date.now

        mockAppConfigService._stubbedTermsAndConditions = .init(
            url: URL(string: "https://www.example.com")!,
            lastUpdated: configLastUpdated
        )
        mockUserDefaultService.set(
            acceptanceDate,
            forKey: .termsAndConditionsAcceptanceDate
        )

        let sut = TermsAndConditionsService(
            appConfigService: mockAppConfigService,
            userDefaultsService: mockUserDefaultService
        )

        #expect(sut.termsAcceptanceIsValid)
    }

    @Test
    func termsAcceptanceIsNotValid_when_lastUpdateLaterThanAcceptance() {
        let mockAppConfigService = MockAppConfigService()
        let mockUserDefaultService = MockUserDefaultsService()
        let configLastUpdated = Date.now
        let acceptanceDate = Date.now.addingTimeInterval(-600)

        mockAppConfigService._stubbedTermsAndConditions = .init(
            url: URL(string: "https://www.example.com")!,
            lastUpdated: configLastUpdated
        )
        mockUserDefaultService.set(
            acceptanceDate,
            forKey: .termsAndConditionsAcceptanceDate
        )

        let sut = TermsAndConditionsService(
            appConfigService: mockAppConfigService,
            userDefaultsService: mockUserDefaultService
        )

        #expect(!sut.termsAcceptanceIsValid)
    }

    @Test
    func termsAcceptanceIsNotValid_when_noAcceptanceDateStored() {
        let mockAppConfigService = MockAppConfigService()
        let mockUserDefaultService = MockUserDefaultsService()
        let configLastUpdated = Date.now

        mockAppConfigService._stubbedTermsAndConditions = .init(
            url: URL(string: "https://www.example.com")!,
            lastUpdated: configLastUpdated
        )

        let sut = TermsAndConditionsService(
            appConfigService: mockAppConfigService,
            userDefaultsService: mockUserDefaultService
        )

        #expect(!sut.termsAcceptanceIsValid)
    }

    @Test
    func saveAcceptanceDate_savesToUserDefaults() {
        let mockAppConfigService = MockAppConfigService()
        let mockUserDefaultService = MockUserDefaultsService()

        let sut = TermsAndConditionsService(
            appConfigService: mockAppConfigService,
            userDefaultsService: mockUserDefaultService
        )

        #expect(mockUserDefaultService.value(forKey: .termsAndConditionsAcceptanceDate) == nil)
        sut.saveAcceptanceDate()
        #expect(mockUserDefaultService.value(forKey: .termsAndConditionsAcceptanceDate) != nil)
    }

    @Test
    func resetAcceptanceDate_removesValueFromUserDefaults() {
        let mockAppConfigService = MockAppConfigService()
        let mockUserDefaultService = MockUserDefaultsService()
        mockUserDefaultService.set(Date.now, forKey: .termsAndConditionsAcceptanceDate)
        
        let sut = TermsAndConditionsService(
            appConfigService: mockAppConfigService,
            userDefaultsService: mockUserDefaultService
        )

        sut.resetAcceptanceDate()
        #expect(mockUserDefaultService.value(forKey: .termsAndConditionsAcceptanceDate) == nil)
    }

    @Test
    func termsAndConditionsUrl_returnsConfigValue() {
        let mockAppConfigService = MockAppConfigService()
        let mockUserDefaultService = MockUserDefaultsService()

        mockAppConfigService._stubbedTermsAndConditions = .init(
            url: URL(string: "https://www.gov.uk")!,
            lastUpdated: .now
        )
        let expectedUrl = mockAppConfigService
            .termsAndConditions?
            .url

        let sut = TermsAndConditionsService(
            appConfigService: mockAppConfigService,
            userDefaultsService: mockUserDefaultService
        )

        #expect(sut.termsAndConditionsURL == expectedUrl)
    }

    @Test
    func hasUpdatedTerms_newUser_returnCorrectResult() {
        let mockAppConfigService = MockAppConfigService()
        let mockUserDefaultService = MockUserDefaultsService()
        let configLastUpdated = Date.now

        mockAppConfigService._stubbedTermsAndConditions = .init(
            url: URL(string: "https://www.example.com")!,
            lastUpdated: configLastUpdated
        )

        let sut = TermsAndConditionsService(
            appConfigService: mockAppConfigService,
            userDefaultsService: mockUserDefaultService
        )

        #expect(!sut.hasUpdatedTerms)
    }

    @Test
    func hasUpdatedTerms_expiredTerms_returnCorrectResult() {
        let mockAppConfigService = MockAppConfigService()
        let mockUserDefaultService = MockUserDefaultsService()
        let configLastUpdated = Date.now
        let acceptanceDate = Date.now.addingTimeInterval(-600)

        mockAppConfigService._stubbedTermsAndConditions = .init(
            url: URL(string: "https://www.example.com")!,
            lastUpdated: configLastUpdated
        )

        mockUserDefaultService.set(
            acceptanceDate,
            forKey: .termsAndConditionsAcceptanceDate
        )

        let sut = TermsAndConditionsService(
            appConfigService: mockAppConfigService,
            userDefaultsService: mockUserDefaultService
        )

        #expect(sut.hasUpdatedTerms)
    }
}
