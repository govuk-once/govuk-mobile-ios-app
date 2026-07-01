import Foundation
import Testing

@testable import govuk_ios
import GovKit
import GovKitUI

@MainActor
struct TaxStatusViewModelBuilderTests {
    let dateFormatter = DateFormatter.dvlaAccount

    // MARK: - Expired
    @Test
    func untaxed_date_returnsExpiredViewModel() async {
        let date = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let sut = TaxStatusViewModelBuilder(urls: nil)
        await confirmation { confirmation in
            let vm = sut.makeViewModel(
                vehicle: CustomerSummary.Vehicle.arrange(
                    taxStatus: .untaxed,
                    taxedUntil: date
                ),
                openURLAction: { _, _ in confirmation() }
            )

            #expect(vm.title == String(localized: .DVLA.taxStatusTitle))
            #expect(vm.status as? TaxStatus == .untaxed)
            #expect(vm.iconName == "exclamationmark.triangle.fill")
            #expect(vm.buttonTitle == String(localized: .DVLA.renewTaxButtonTitle))
            #expect(vm.progressViewModel == nil)
            #expect(vm.formattedStatus == String(
                localized: .DVLA.expiredOn(date: dateFormatter.string(from: date)))
            )

            vm.buttonAction?()
        }
    }

    // MARK: - Expired
    @Test
    func untaxed_noDate_returnsExpiredViewModel() {
        let sut = TaxStatusViewModelBuilder(urls: nil)
        let vm = sut.makeViewModel(
            vehicle: CustomerSummary.Vehicle.arrange(
                taxStatus: .untaxed,
                taxedUntil: nil,
            ),
            openURLAction: { _, _ in }
        )

        #expect(vm.formattedStatus == "Expired")
    }

    // MARK: - Valid
    @Test
    func taxed_longDate_returnsValidViewModel() {
        let date = Calendar.current.date(byAdding: .day, value: 60, to: Date())!
        let sut = TaxStatusViewModelBuilder(urls: nil)
        let vm = sut.makeViewModel(
            vehicle: CustomerSummary.Vehicle.arrange(
                taxStatus: .taxed,
                taxedUntil: date
            ),
            openURLAction: { _, _ in }
        )

        #expect(vm.title == String(localized: .DVLA.taxStatusTitle))
        #expect(vm.status as? TaxStatus == .taxed)
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
        let sut = TaxStatusViewModelBuilder(urls: nil)
        let vm = sut.makeViewModel(
            vehicle: CustomerSummary.Vehicle.arrange(
                taxStatus: .taxed,
                taxedUntil: nil
            ),
            openURLAction: { _, _ in }
        )

        #expect(vm.title == String(localized: .DVLA.taxStatusTitle))
        #expect(vm.status as? TaxStatus == .taxed)
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
        let sut = TaxStatusViewModelBuilder(urls: nil)
        await confirmation { confirmation in
            let vm = sut.makeViewModel(
                vehicle: CustomerSummary.Vehicle.arrange(
                    taxStatus: .taxed,
                    taxedUntil: date,
                    currentLicence: CurrentLicence(paymentMethod: nil)
                ),
                openURLAction: { _, _ in confirmation() }
            )

            #expect(vm.title == String(localized: .DVLA.taxStatusTitle))
            #expect(vm.status as? TaxStatus == .taxed)
            #expect(vm.progressViewModel != nil)
            #expect(vm.buttonTitle == String(localized: .DVLA.renewTaxButtonTitle))
            #expect(vm.formattedStatus == String(
                localized: .DVLA.expiringOn(date: dateFormatter.string(from: date)))
            )
            #expect(vm.footer == String(localized: .DVLA.renewTaxExpiringFooter))

            vm.buttonAction?()
        }
    }

    // MARK: - Expiring
    @Test
    func taxed_expiringDate_directDebit_returnsExpiringViewModel() async {
        let date = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        let sut = TaxStatusViewModelBuilder(urls: nil)
        await confirmation { confirmation in
            let vm = sut.makeViewModel(
                vehicle: CustomerSummary.Vehicle.arrange(
                    taxStatus: .taxed,
                    taxedUntil: date,
                    currentLicence: CurrentLicence(paymentMethod: "Direct Debit")
                ),
                openURLAction: { _, _ in confirmation() }
            )

            #expect(vm.title == String(localized: .DVLA.taxStatusTitle))
            #expect(vm.status as? TaxStatus == .taxed)
            #expect(vm.progressViewModel != nil)
            #expect(vm.buttonTitle == String(localized: .DVLA.expiringTaxManagePaymentButtonTitle))
            #expect(vm.formattedStatus == String(
                localized: .DVLA.renewsOn(date: dateFormatter.string(from: date)))
            )

            vm.buttonAction?()
        }
    }

    // MARK: - Unknown
    @Test
    func unknown_returnsUnknownViewModel() {
        let sut = TaxStatusViewModelBuilder(urls: nil)
        let vm = sut.makeViewModel(
            vehicle: CustomerSummary.Vehicle.arrange(
                taxStatus: nil
            ),
            openURLAction: { _, _ in }
        )

        #expect(vm.title == String(localized: .DVLA.taxStatusTitle))
        #expect(vm.status as? TaxStatus == nil)
        #expect(vm.progressViewModel == nil)
        #expect(vm.formattedStatus == String(
            localized: .DVLA.unknown
        ))
    }

    // MARK: - Sorn
    @Test
    func sorn_returnsSornViewModel() {
        let date = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let sut = TaxStatusViewModelBuilder(urls: nil)
        let vm = sut.makeViewModel(
            vehicle: CustomerSummary.Vehicle.arrange(
                taxStatus: .sorn,
                sornStart: date
            ),
            openURLAction: { _, _ in }
        )

        #expect(vm.title == nil)
        #expect(vm.status as? TaxStatus == .sorn)
        #expect(vm.iconName == "parkingsign.brakesignal")
        #expect(vm.progressViewModel == nil)
        #expect(vm.formattedStatus == String(
            localized: .DVLA.offTheRoadSorn
        ))
        #expect(vm.footer == String(
            localized: .DVLA.from(date: dateFormatter.string(from: date))
        ))
    }

    // MARK: - Not needed
    @Test
    func notTaxedForOnRoadUse_returnsNotNeededViewModel() {
        let date = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        let sut = TaxStatusViewModelBuilder(urls: nil)
        let vm = sut.makeViewModel(
            vehicle: CustomerSummary.Vehicle.arrange(
                taxStatus: .notTaxedForOnRoadUse,
                sornStart: date
            ),
            openURLAction: { _, _ in }
        )

        #expect(vm.title == String(localized: .DVLA.taxStatusTitle))
        #expect(vm.status as? TaxStatus == .notTaxedForOnRoadUse)
        #expect(vm.progressViewModel == nil)
        #expect(vm.formattedStatus == String(
            localized: .DVLA.vehicleTaxNotNeeded
        ))
    }
}
