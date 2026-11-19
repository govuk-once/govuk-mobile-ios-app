import Foundation
import Combine

@MainActor
class BenefitsContainerViewModel: ObservableObject {
    @Published var selectedTab: BenefitTab = .yourBenefits
    @Published var benefits: [BenefitItem] = []
    @Published var selectedHistoryBenefit: BenefitItem?

    init() {
        loadBenefits()
    }

    var filteredBenefits: [BenefitItem] {
        benefits.filter { $0.category == selectedTab }
    }

    func loadBenefits() {
        benefits = [
            BenefitItem(
                title: "State Pension",
                frequency: "Paid every 4 weeks",
                amount: "£884.80",
                nextPaymentText: "1 November 2027 (in 2 days)",
                category: .yourBenefits
            ),
            BenefitItem(
                title: "Winter Fuel Payment",
                frequency: "Paid annually",
                amount: "£200.00",
                nextPaymentText: "15 November 2027 (in 16 days)",
                category: .yourBenefits
            ),
            BenefitItem(
                title: "Pension Credit",
                frequency: "Check eligibility",
                amount: "£0.00",
                nextPaymentText: "Available to claim",
                category: .otherBenefits
            )
        ]
    }

    func toggleAmountVisibility(for id: UUID) {
        if let index = benefits.firstIndex(where: { $0.id == id }) {
            benefits[index].isAmountHidden.toggle()
        }
    }

    func selectPaymentHistory(for benefit: BenefitItem) {
        selectedHistoryBenefit = benefit
    }
}

enum BenefitTab: String, CaseIterable, Identifiable, Hashable {
    case yourBenefits = "Your Benefits"
    case otherBenefits = "Other Benefits"
    var id: String { rawValue }
}
