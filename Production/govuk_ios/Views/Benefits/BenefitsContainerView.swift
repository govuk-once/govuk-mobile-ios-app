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
            switch viewModel.selectedTab {
            case .yourBenefits:
                benefitsList
            case .otherBenefits:
                benefitsList
            }
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
    }

    private var viewPicker: some View {
        Picker("Benefits", selection: $viewModel.selectedTab) {
            ForEach(BenefitTab.allCases) { tab in
                Text(tab.rawValue)
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
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(benefit.title)
                                    .font(Font.govUK.title2Bold)
                                    .foregroundColor(Color(UIColor.govUK.text.primary))
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("Paid every 4 weeks")
                                    .font(Font.govUK.subheadline)
                                    .foregroundColor(Color(UIColor.govUK.text.secondary))
                            }
                            Spacer()
                            Button {
                            } label: {
                                Image(systemName: "ellipsis.circle.fill")
                                    .foregroundColor(
                                        Color(UIColor.govUK.text.link)
                                    )
                                    .font(Font.govUK.title1)
                                    .fontWeight(.bold)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer().frame(height: 16)
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Text(benefit.isAmountHidden ? "£**.**" : benefit.amount)
                                    .foregroundColor(Color(UIColor.govUK.text.primary))
                                    .font(Font.govUK.bodySemibold)
                                Button {
                                } label: {
                                    Image(systemName: benefit.isAmountHidden ? "eye.slash" : "eye"
                                    )
                                        .foregroundColor(Color(UIColor.govUK.text.primary))
                                        .fontWeight(.semibold)
                                }
                                .buttonStyle(.plain)
                            }
                            Text(benefit.nextPaymentText)
                                .font(Font.govUK.body)
                                .foregroundColor(
                                    Color(
                                        UIColor.govUK.text.primary
                                    )
                                )
                        }
                        Rectangle()
                            .fill(Color(UIColor.govUK.strokes.listDivider))
                            .frame(height: 1)
                            .padding(.vertical, 14)
                        Button {
                        } label: {
                            HStack {
                                Text("Payment history")
                                    .foregroundColor(
                                        Color(UIColor.govUK.text.primary)
                                    )
                                    .font(Font.govUK.body)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(Font.govUK.bodySemibold)
                                    .foregroundColor(
                                        Color(UIColor.govUK.text.iconTertiary)
                                    )
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
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
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}
