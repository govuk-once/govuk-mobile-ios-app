import SwiftUI
import GovKit
import GovKitUI

struct BenefitsContainerView: View {
    @StateObject private var viewModel: BenefitsContainerViewModel

    init(viewModel: BenefitsContainerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            viewPicker
                .padding(.bottom, 16)
            benefitsList
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
    }

    private var viewPicker: some View {
        Picker("Benefits", selection: $viewModel.selectedTab) {
            ForEach(BenefitsTab.allCases) { tab in
                Text(tab.title)
                    .foregroundColor(Color(UIColor.govUK.text.primary))
                    .tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
    }

    private var benefitsList: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(viewModel.filteredBenefits) { benefit in
                    BenefitsSummaryCardView(
                        benefit: benefit,
                        onToggleVisibility: { /*Donothing*/ },
                        onMoreActions: { /*Do nothing*/ },
                        onPaymentHistory: { /*Do nothing*/ }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

private struct BenefitsSummaryCardView: View {
    let benefit: BenefitsSummaryCard
    let onToggleVisibility: () -> Void
    let onMoreActions: () -> Void
    let onPaymentHistory: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            Spacer().frame(height: 16)
            paymentSection
            Divider()
                .background(Color(UIColor.govUK.strokes.listDivider))
                .padding(.vertical, 14)
            paymentHistoryButton
        }
        .padding(20)
        .background(Color(UIColor.govUK.fills.surfaceCardDefault))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }

    private var headerSection: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(benefit.title)
                    .font(Font.govUK.title2Bold)
                    .foregroundColor(Color(UIColor.govUK.text.primary))
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                Text(benefit.frequency)
                    .font(Font.govUK.subheadline)
                    .foregroundColor(Color(UIColor.govUK.text.secondary))
            }
            Spacer()
            Button(action: onMoreActions) {
                Image(systemName: "ellipsis.circle.fill")
                    .foregroundColor(Color(UIColor.govUK.text.link))
                    .font(Font.govUK.title1)
                    .fontWeight(.bold)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("More options for \(benefit.title)")
        }
    }

    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(benefit.isAmountHidden ? "£**.**" : benefit.amount)
                    .foregroundColor(Color(UIColor.govUK.text.primary))
                    .font(Font.govUK.bodySemibold)
                    .accessibilityLabel(benefit.isAmountHidden ? "Amount hidden" : benefit.amount)

                Button(action: onToggleVisibility) {
                    Image(systemName: benefit.isAmountHidden ? "eye.slash" : "eye")
                        .foregroundColor(Color(UIColor.govUK.text.primary))
                        .fontWeight(.semibold)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(benefit.isAmountHidden ? "Show \(benefit.title) amount" : "Hide \(benefit.title) amount")
            }
            Text(benefit.nextPaymentText)
                .font(Font.govUK.body)
                .foregroundColor(Color(UIColor.govUK.text.primary))
        }
    }

    private var paymentHistoryButton: some View {
        Button(action: onPaymentHistory) {
            HStack {
                Text("Payment history")
                    .foregroundColor(Color(UIColor.govUK.text.primary))
                    .font(Font.govUK.body)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(Font.govUK.bodySemibold)
                    .foregroundColor(Color(UIColor.govUK.text.iconTertiary))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}
