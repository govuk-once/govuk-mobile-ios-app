import SwiftUI
import Foundation
import GovKit

struct LicenceCategoriesListView: View {
    @ObservedObject var viewModel: LicenceCategoriesViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Top Header
                VStack(alignment: .leading, spacing: 12) {
                    Text(.DVLA.licenceCategoriesExplanation)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                .padding(.top, 8)

                // "You can drive"
                if !viewModel.entitledToDrive.isEmpty {
                    EntitlementMajorSectionView(
                        title: String(localized:
                                .DVLA.entitlementSectionTitleYouCanDrive
                        ),
                        groups: viewModel.entitledToDrive,
                        showsHighlight: viewModel.showsRowHighlight,
                        onSelectRow: { entitlement in
                            viewModel.onRowTap(entitlement)
                        }
                    )
                }

                // "You can provisionally drive"
                if !viewModel.provisionallyEntitledToDrive.isEmpty {
                    EntitlementMajorSectionView(
                        title: String(localized:
                                .DVLA.entitlementSectionTitleYouCanProvisionallyDrive
                        ),
                        groups: viewModel.provisionallyEntitledToDrive,
                        showsHighlight: viewModel.showsRowHighlight,
                        onSelectRow: { entitlement in
                            viewModel.onRowTap(entitlement)
                        }
                    )
                }

                // "Further information"
                if !viewModel.links.isEmpty {
                    FurtherInformationSectionView(
                        links: viewModel.links,
                        onLinkClick: { link in
                            viewModel.onLinkClick(link)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }
}

// MARK: -

struct LicenceCategoriesView: View {
    @ObservedObject var viewModel: LicenceCategoriesViewModel

    var body: some View {
        LicenceCategoriesListView(viewModel: viewModel)
            .navigationTitle(String(localized:
                    .DVLA.licenceCategoriesListTitle
            ))
            .navigationBarTitleDisplayMode(.large)
            .background(Color(uiColor: .govUK.fills.surfaceFullscreen))
            .onAppear {
                viewModel.trackScreen(screen: self)
            }
    }
}

extension LicenceCategoriesView: TrackableScreen {
    var trackingTitle: String? { "Categories" }
    var trackingName: String { "Categories" }
}

#if DEBUG
extension Entitlement {
    static func preview(
        id: UUID = UUID(),
        categoryCode: String,
        categoryType: CategoryType,
        categoryLegalLiteral: String = "",
        fromDate: Date = Date(),
        expiryDate: Date = Calendar.current.date(byAdding: .year, value: 10, to: Date()) ?? Date(),
        restrictions: [EntitlementRestriction] = []
    ) -> Entitlement {
        Entitlement(
            id: id,
            categoryCode: categoryCode,
            categoryLegalLiteral: categoryLegalLiteral.isEmpty ? "Category \(categoryCode)" : categoryLegalLiteral,
            categoryType: categoryType,
            fromDate: fromDate,
            expiryDate: expiryDate,
            restrictions: restrictions
        )
    }
}
#endif

#Preview("Categories Screen") {
    let sampleEntitlements: [Entitlement] = [
        // You can drive
        .preview(categoryCode: "P", categoryType: .full),
        .preview(categoryCode: "AM", categoryType: .full),
        .preview(categoryCode: "Q", categoryType: .full),
        .preview(categoryCode: "A", categoryType: .full),
        .preview(categoryCode: "B1", categoryType: .full),
        .preview(categoryCode: "B", categoryType: .full),
        .preview(categoryCode: "BE", categoryType: .full),
        .preview(categoryCode: "C1", categoryType: .full),
        .preview(categoryCode: "C1E", categoryType: .full),
        .preview(categoryCode: "D1", categoryType: .full),
        .preview(categoryCode: "D1E", categoryType: .full),
        .preview(categoryCode: "F", categoryType: .full),
        .preview(categoryCode: "K", categoryType: .full),
        .preview(categoryCode: "L", categoryType: .full),
        .preview(categoryCode: "N", categoryType: .full),

        // You can provisionally drive
        .preview(categoryCode: "A", categoryType: .provisional),
        .preview(categoryCode: "G", categoryType: .provisional),
        .preview(categoryCode: "H", categoryType: .provisional)
    ]

    let viewModel = LicenceCategoriesViewModel(
        entitlements: sampleEntitlements,
        showsRowHighlight: true,
        actions: .init(
            didSelectAction: { selected in
                print("Selected Entitlement: \(selected.categoryCode) (\(selected.categoryType))")
            },
            openURLAction: nil,
            dismissAction: {}
        ),
        links: [],
        analyticsService: MockAnalyticsService()
    )

    NavigationStack {
        LicenceCategoriesListView(viewModel: viewModel)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // nothing
                    }
                    label: {
                        Image(systemName: "arrow.backward")
                            .foregroundStyle(.primary)
                    }
                }
            }
    }
}
