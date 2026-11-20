import Foundation

struct BenefitsSummaryCard: Identifiable {
    let id = UUID()
    let title: String
    let frequency: String
    let amount: String
    let nextPaymentText: String
    let category: BenefitTab
    var isAmountHidden: Bool = true
}
