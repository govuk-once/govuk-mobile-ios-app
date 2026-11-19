import Foundation
import Combine

@MainActor
class BenefitsContainerViewModel: ObservableObject {
    @Published var selectedTab: BenefitTab = .yourBenefits
    @Published var benefits: [BenefitsSummaryCard] = []

    init() {
        loadBenefits()
    }

    var filteredBenefits: [BenefitsSummaryCard] {
        benefits.filter { $0.category == selectedTab }
    }

    func loadBenefits() {
        benefits = [
            BenefitsSummaryCard(
                title: "State Pension",
                frequency: "Paid every 4 weeks",
                amount: "£884.80",
                nextPaymentText: "1 November 2027 (in 2 days)",
                category: .yourBenefits
            ),
            BenefitsSummaryCard(
                title: "Winter Fuel Payment",
                frequency: "Paid annually",
                amount: "£200.00",
                nextPaymentText: "15 November 2027 (in 16 days)",
                category: .yourBenefits
            ),
            BenefitsSummaryCard(
                title: "Pension Credit",
                frequency: "Check eligibility",
                amount: "£0.00",
                nextPaymentText: "Available to claim",
                category: .otherBenefits
            )
        ]
    }
}

enum BenefitTab: String, CaseIterable, Identifiable, Hashable {
    case yourBenefits = "Your Benefits"
    case otherBenefits = "Other Benefits"
    var id: String { rawValue }
}
