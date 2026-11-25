import Foundation

struct BenefitsSummaryCard: Identifiable {
    let id = UUID()
    let title: String
    let frequency: String
    let amount: String
    let nextPaymentText: String
    let category: BenefitsTab
    var isAmountHidden: Bool = true
}
