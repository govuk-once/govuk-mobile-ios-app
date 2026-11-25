import Testing
import Foundation

@testable import govuk_ios

@MainActor
struct BenefitsContainerViewModelTests {

    @Test
    func init_setsDefaultTab_and_loadsBenefits() {
        let sut = BenefitsContainerViewModel()

        #expect(sut.selectedTab == .yourBenefits)
        #expect(sut.benefits.count == 3)
    }

    @Test
    func loadBenefits_populatesExpectedBenefitsData() {
        let sut = BenefitsContainerViewModel()
        sut.benefits = []

        sut.loadBenefits()

        #expect(sut.benefits.count == 3)

        let statePension = sut.benefits.first { $0.title == "State Pension" }
        #expect(statePension?.frequency == "Paid every 4 weeks")
        #expect(statePension?.amount == "£884.80")
        #expect(statePension?.nextPaymentText == "1 November 2027 (in 2 days)")
        #expect(statePension?.category == .yourBenefits)

        let winterFuel = sut.benefits.first { $0.title == "Winter Fuel Payment" }
        #expect(winterFuel?.frequency == "Paid annually")
        #expect(winterFuel?.amount == "£200.00")
        #expect(winterFuel?.nextPaymentText == "15 November 2027 (in 16 days)")
        #expect(winterFuel?.category == .yourBenefits)

        let pensionCredit = sut.benefits.first { $0.title == "Pension Credit" }
        #expect(pensionCredit?.frequency == "Check eligibility")
        #expect(pensionCredit?.amount == "£0.00")
        #expect(pensionCredit?.nextPaymentText == "Available to claim")
        #expect(pensionCredit?.category == .otherBenefits)
    }

    @Test
    func filteredBenefits_whenYourBenefitsSelected_returnsOnlyYourBenefits() {
        let sut = BenefitsContainerViewModel()
        sut.selectedTab = .yourBenefits

        let filtered = sut.filteredBenefits

        #expect(filtered.count == 2)
        #expect(filtered.allSatisfy { $0.category == .yourBenefits })
        #expect(filtered.map(\.title) == ["State Pension", "Winter Fuel Payment"])
    }

    @Test
    func filteredBenefits_whenOtherBenefitsSelected_returnsOnlyOtherBenefits() {
        let sut = BenefitsContainerViewModel()
        sut.selectedTab = .otherBenefits

        let filtered = sut.filteredBenefits

        #expect(filtered.count == 1)
        #expect(filtered.allSatisfy { $0.category == .otherBenefits })
        #expect(filtered.first?.title == "Pension Credit")
    }

    @Test
    func benefitsTab_properties_returnExpectedValues() {
        #expect(BenefitsTab.allCases == [.yourBenefits, .otherBenefits])

        #expect(BenefitsTab.yourBenefits.id == "yourBenefits")
        #expect(BenefitsTab.yourBenefits.title == "Your Benefits")

        #expect(BenefitsTab.otherBenefits.id == "otherBenefits")
        #expect(BenefitsTab.otherBenefits.title == "Other Benefits")
    }
}

