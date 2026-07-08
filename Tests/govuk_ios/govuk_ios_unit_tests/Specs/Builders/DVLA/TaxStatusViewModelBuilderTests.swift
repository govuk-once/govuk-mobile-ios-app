import Foundation
import Testing

@testable import govuk_ios
import GovKit
import GovKitUI

@MainActor
struct TaxStatusViewModelBuilderTests {
    let dateFormatter = DateFormatter.dvlaAccount
    let urls = DvlaURLs.arrange()

    // MARK: - Expired
    @Test
    func untaxed_date_returnsExpiredViewModel() async {
        let date = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let mockAnalyticsService = MockAnalyticsService()
        await confirmation { confirmation in
            let sut = TaxStatusViewModelBuilder(
                urls: urls,
                analyticsService: mockAnalyticsService,
                openURLAction: { _ in confirmation() }
            )
            let vm = sut.makeViewModel(
                vehicle: CustomerSummary.Vehicle.arrange(
                    taxStatus: .untaxed,
                    taxedUntil: date
                )
            )

            #expect(vm.title == String(localized: .DVLA.taxStatusTitle))
            #expect(vm.iconName == "exclamationmark.triangle.fill")
            #expect(vm.buttonTitle == String(localized: .DVLA.renewTaxButtonTitle))
            #expect(vm.progressViewModel == nil)
            #expect(vm.formattedStatus == String(
                localized: .DVLA.expiredOn(date: dateFormatter.string(from: date)))
            )

            vm.buttonAction?()

            let event = mockAnalyticsService._trackedEvents.first
            #expect(mockAnalyticsService._trackedEvents.count == 1)
            #expect(event?.params?["text"] as? String == String(localized: .DVLA.renewTaxButtonTitle))
            #expect(event?.params?["type"] as? String == "Button")
            #expect(event?.params?["url"] as? String == urls.taxVehicle?.absoluteString)
        }
    }

    // MARK: - Expired
    @Test
    func untaxed_noDate_returnsExpiredViewModel() {
        let sut = TaxStatusViewModelBuilder(
            urls: nil,
            analyticsService: MockAnalyticsService(),
            openURLAction: { _ in }
        )
        let vm = sut.makeViewModel(
            vehicle: CustomerSummary.Vehicle.arrange(
                taxStatus: .untaxed,
                taxedUntil: nil
            )
        )

        #expect(vm.formattedStatus == "Expired")
    }

    // MARK: - Valid
    @Test
    func taxed_longDate_returnsValidViewModel() {
        let date = Calendar.current.date(byAdding: .day, value: 60, to: Date())!
        let sut = TaxStatusViewModelBuilder(
            urls: nil,
            analyticsService: MockAnalyticsService(),
            openURLAction: { _ in }
        )
        let vm = sut.makeViewModel(
            vehicle: CustomerSummary.Vehicle.arrange(
                taxStatus: .taxed,
                taxedUntil: date
            )
        )

        #expect(vm.title == String(localized: .DVLA.taxStatusTitle))
        #expect(vm.iconName == "checkmark.circle.fill")
        #expect(vm.progressViewModel == nil)
        #expect(vm.buttonTitle == nil)
        #expect(vm.formattedStatus == String(
            localized: .DVLA.validUntil(date: dateFormatter.string(from: date)))
        )
    }

    // MARK: - Valid
    @Test
    func taxed_noDate_returnsValidViewModel() {
        let sut = TaxStatusViewModelBuilder(
            urls: nil,
            analyticsService: MockAnalyticsService(),
            openURLAction: { _ in }
        )
        let vm = sut.makeViewModel(
            vehicle: CustomerSummary.Vehicle.arrange(
                taxStatus: .taxed,
                taxedUntil: nil
            )
        )

        #expect(vm.title == String(localized: .DVLA.taxStatusTitle))
        #expect(vm.iconName == "checkmark.circle.fill")
        #expect(vm.progressViewModel == nil)
        #expect(vm.buttonTitle == nil)
        #expect(vm.formattedStatus == String(
            localized: .DVLA.valid)
        )
    }

    // MARK: - Expiring
    @Test
    func taxed_expiringDate_noDirectDebit_returnsExpiringViewModel() async {
        let date = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        let mockAnalyticsService =  MockAnalyticsService()
        await confirmation { confirmation in
            let sut = TaxStatusViewModelBuilder(
                urls: urls,
                analyticsService: mockAnalyticsService,
                openURLAction: { _ in confirmation() }
            )
            let vm = sut.makeViewModel(
                vehicle: CustomerSummary.Vehicle.arrange(
                    taxStatus: .taxed,
                    taxedUntil: date,
                    currentLicence: CurrentLicence(paymentMethod: nil)
                )
            )

            #expect(vm.title == String(localized: .DVLA.taxStatusTitle))
            #expect(vm.progressViewModel != nil)
            #expect(vm.buttonTitle == String(localized: .DVLA.renewTaxButtonTitle))
            #expect(vm.formattedStatus == String(
                localized: .DVLA.expiringOn(date: dateFormatter.string(from: date)))
            )
            #expect(vm.footer == String(localized: .DVLA.renewTaxExpiringFooter))

            vm.buttonAction?()

            let event = mockAnalyticsService._trackedEvents.first
            #expect(mockAnalyticsService._trackedEvents.count == 1)
            #expect(event?.params?["text"] as? String == String(localized: .DVLA.renewTaxButtonTitle))
            #expect(event?.params?["type"] as? String == "Button")
            #expect(event?.params?["url"] as? String == urls.taxVehicle?.absoluteString)
        }
    }

    // MARK: - Expiring
    @Test
    func taxed_expiringDate_directDebit_returnsExpiringViewModel() async {
        let date = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        let mockAnalyticsService = MockAnalyticsService()
        await confirmation { confirmation in
            let sut = TaxStatusViewModelBuilder(
                urls: urls,
                analyticsService: mockAnalyticsService,
                openURLAction: { _ in confirmation() }
            )
            let vm = sut.makeViewModel(
                vehicle: CustomerSummary.Vehicle.arrange(
                    taxStatus: .taxed,
                    taxedUntil: date,
                    currentLicence: CurrentLicence(paymentMethod: "Direct Debit")
                )
            )

            #expect(vm.title == String(localized: .DVLA.taxStatusTitle))
            #expect(vm.progressViewModel != nil)
            #expect(vm.buttonTitle == String(localized: .DVLA.expiringTaxManagePaymentButtonTitle))
            #expect(vm.formattedStatus == String(
                localized: .DVLA.renewsOn(date: dateFormatter.string(from: date)))
            )
            #expect(vm.footer == String(localized: .DVLA.renewTaxExpiringFooter))

            vm.buttonAction?()

            let event = mockAnalyticsService._trackedEvents.first
            #expect(mockAnalyticsService._trackedEvents.count == 1)
            #expect(event?.params?["text"] as? String == String(localized: .DVLA.expiringTaxManagePaymentButtonTitle))
            #expect(event?.params?["type"] as? String == "Button")
            #expect(event?.params?["url"] as? String == urls.manageTaxPayment?.absoluteString)
        }
    }

    // MARK: - Unknown
    @Test
    func unknown_returnsUnknownViewModel() {
        let sut = TaxStatusViewModelBuilder(
            urls: nil,
            analyticsService: MockAnalyticsService(),
            openURLAction: { _ in }
        )
        let vm = sut.makeViewModel(
            vehicle: CustomerSummary.Vehicle.arrange(
                taxStatus: nil
            )
        )

        #expect(vm.title == String(localized: .DVLA.taxStatusTitle))
        #expect(vm.progressViewModel == nil)
        #expect(vm.formattedStatus == String(
            localized: .DVLA.unknown
        ))
    }

    // MARK: - Sorn
    @Test
    func sorn_returnsSornViewModel() {
        let date = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let sut = TaxStatusViewModelBuilder(
            urls: nil,
            analyticsService: MockAnalyticsService(),
            openURLAction: { _ in }
        )
        let vm = sut.makeViewModel(
            vehicle: CustomerSummary.Vehicle.arrange(
                taxStatus: .sorn,
                sornStart: date
            )
        )

        #expect(vm.title == nil)
        #expect(vm.status as? TaxValidityStatus == .sorn)
        #expect(vm.iconName == "parkingsign.brakesignal")
        #expect(vm.progressViewModel == nil)
        #expect(vm.formattedStatus == String(
            localized: .DVLA.offTheRoadSorn
        ))
        #expect(vm.footer == String(
            localized: .DVLA.from(date: dateFormatter.string(from: date))
        ))
    }

    // MARK: - Future sorn
    @Test
    func sorn_future_returnsSornViewModel() {
        let date = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        let sut = TaxStatusViewModelBuilder(
            urls: nil,
            analyticsService: MockAnalyticsService(),
            openURLAction: { _ in }
        )
        let vm = sut.makeViewModel(
            vehicle: CustomerSummary.Vehicle.arrange(
                taxStatus: .taxed,
                sornStart: date
            )
        )

        #expect(vm.title == nil)
        #expect(vm.status as? TaxValidityStatus == .futureSorn)
        #expect(vm.iconName == "parkingsign.brakesignal")
        #expect(vm.progressViewModel == nil)
        #expect(vm.formattedStatus == String(
            localized: .DVLA.offTheRoadSorn
        ))
        #expect(vm.footer == nil)
    }

    // MARK: - Not needed
    @Test
    func notTaxedForOnRoadUse_returnsNotNeededViewModel() {
        let date = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        let sut = TaxStatusViewModelBuilder(
            urls: nil,
            analyticsService: MockAnalyticsService(),
            openURLAction: { _ in }
        )
        let vm = sut.makeViewModel(
            vehicle: CustomerSummary.Vehicle.arrange(
                taxStatus: .notTaxedForOnRoadUse,
                sornStart: date
            )
        )

        #expect(vm.title == String(localized: .DVLA.taxStatusTitle))
        #expect(vm.progressViewModel == nil)
        #expect(vm.formattedStatus == String(
            localized: .DVLA.vehicleTaxNotNeeded
        ))
    }
}
