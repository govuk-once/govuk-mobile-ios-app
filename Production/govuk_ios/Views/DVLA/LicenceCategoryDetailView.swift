import SwiftUI
import GovKit

struct LicenceCategoryDetailView: View {
    @StateObject private var viewModel: LicenceCategoryDetailViewModel

    init(viewModel: LicenceCategoryDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.categoryGroupTitle)
                    .font(.govUK.title1Bold)
                Text(.DVLA.categoryTitle)
                    .padding(.top, 36)
                HStack {
                    if let icon = viewModel.categoryIcon {
                        Spacer()
                        Image(icon)
                            .renderingMode(.template)
                            .tint(Color(uiColor: .govUK.text.primary))
                            .font(.system(size: 32))
                            .padding(16)
                        Spacer()
                        Divider()
                            .foregroundStyle(Color(uiColor: .govUK.strokes.listDivider))
                            .padding(16)
                    }
                    Spacer()
                    Text(viewModel.categoryCode)
                        .font(.govUK.largeTitleBold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 30)
                    Spacer()
                }
                Divider()
                    .foregroundStyle(Color(uiColor: .govUK.strokes.listDivider))
                labeledRow(label: String(localized: .DVLA.validFrom), value: viewModel.validFrom)
                Divider()
                    .foregroundStyle(Color(uiColor: .govUK.strokes.listDivider))
                labeledRow(label: String(localized: .DVLA.validTo), value: viewModel.validTo)
                restrictionListView
                Text(.DVLA.categoryDescriptionTitle)
                    .font(.govUK.title2Bold)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.top, 48)
                    .padding(.bottom, 16)
                Text(viewModel.categoryDescription)
                    .font(.govUK.body)
            }
            .padding(.horizontal, 16)
        }
        .background(Color(uiColor: .govUK.fills.surfaceFullscreen))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .tint(Color(uiColor: .govUK.text.link))
                }
            }
        }
        .onAppear {
            viewModel.trackScreen(screen: self)
        }
    }

    @ViewBuilder
    private var restrictionListView: some View {
        if !viewModel.restrictionRows.isEmpty {
            Text(.DVLA.restrictionsTitle)
                .font(.govUK.title2Bold)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, 48)
                .padding(.bottom, 16)
            ForEach(viewModel.restrictionRows) { row in
                restrictionRow(
                    label: row.code,
                    value: row.description
                )
            }
        }
    }

    private func labeledRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.govUK.body)
            Spacer()
            Text(value)
                .font(.govUK.bodySemibold)
        }
        .padding(.vertical, 16)
    }

    private func restrictionRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.govUK.bodySemibold)
            Text(value)
                .font(.govUK.body)
        }
    }
}

extension LicenceCategoryDetailView: TrackableScreen {
    var trackingTitle: String? { viewModel.categoryGroupTitle }
    var trackingName: String { viewModel.categoryGroupTitle }
}

#Preview {
    let entitlement = Entitlement(
        categoryCode: "C",
        categoryLegalLiteral: """
Vehicles weighing over 3,500 kg (with a trailer up to 750 kg), with no more than
8 passengers and driver
""",
        categoryType: .full,
        fromDate: Date(),
        expiryDate: Date().addingTimeInterval(1800000),
        restrictions: [
            .init(restrictionCode: "101", restrictionLiteral: "Not for Hire or reward"),
            .init(restrictionCode: "119", restrictionLiteral: "Weight limit does not apply")
        ]
    )
    let viewModel = LicenceCategoryDetailViewModel(
        entitlement: entitlement,
        analyticsService: MockAnalyticsService(),
        dismissAction: {
            print("dismiss tapped")
        }
    )
    LicenceCategoryDetailView(viewModel: viewModel)
}
