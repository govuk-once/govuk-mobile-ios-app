import SwiftUI
import Foundation

struct VMCategoriesListView: View {
    @ObservedObject var viewModel: CategoriesViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Top Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("""
                        Your licence categories and \
                        codes show which vehicles you can \
                        drive and any restrictions or \
                        requirements. Check each category \
                        for restrictions and expiry dates.
                        """)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                .padding(.top, 8)

                // "You can drive"
                if !viewModel.entitledToDrive.isEmpty {
                    EntitlementMajorSectionView(
                        title: "You can drive",
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
                        title: "You can provisionally drive",
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

// MARK: - Sheet Presentation View

struct VMCategoriesSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CategoriesViewModel

    var body: some View {
        NavigationStack {
            VMCategoriesListView(viewModel: viewModel)
                .navigationTitle("Categories")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.secondary)
                                .frame(width: 32, height: 32)
                                .background(Color(.systemGray5))
                                .clipShape(Circle())
                        }
                    }
                }
        }
    }
}

/*
struct DrivingLicenceParentView: View {
    @State private var showSheet = false
    @StateObject private var viewModel = CategoriesViewModel(
        entitledToDrive: [
            "Mopeds, AM, p, q",
            "Motorcycles, A",
            "Cars, B",
            "Trailers, BE, C1E, D1E"
        ],
        provisionallyEntitledToDrive: [
            "Motorcycles, A",
            "Road roller, G",
            "Tracked vehicles, H"
        ],
        links: [
            CategoryLink(
                text: "Driving licence categories",
                url: URL(string: "https://www.gov.uk/driving-licence-categories")!
            ),
            CategoryLink(
                text: "Driving licence codes",
                url: URL(string: "https://www.gov.uk/driving-licence-codes")!
            )
        ]
    )

    var body: some View {
        Button("View Categories") {
            showSheet = true
        }
        .sheet(isPresented: $showSheet) {
            VMCategoriesSheetView(viewModel: viewModel)
        }
    }
}

#Preview("Parent View") {
    DrivingLicenceParentView()
}
 */
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

    let sampleLinks = [
        CategoryLink(
            text: "Compare old and new categories",
            url: URL(string: "https://www.gov.uk/driving-licence-categories")!
        ),
        CategoryLink(
            text: "Vehicle weights explained",
            url: URL(string: "https://www.gov.uk/vehicle-weights-explained")!
        ),
        CategoryLink(
            text: "Adding categories to your licence",
            url: URL(string: "https://www.gov.uk/adding-higher-categories-to-your-driving-licence")!
        )
    ]

    let viewModel = CategoriesViewModel(
        entitlements: sampleEntitlements,
        links: sampleLinks,
        showsRowHighlight: true,
        onRowSelected: { selected in
            print("Selected Entitlement: \(selected.categoryCode) (\(selected.categoryType))")
        }
    )

    NavigationStack {
        VMCategoriesListView(viewModel: viewModel)
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
