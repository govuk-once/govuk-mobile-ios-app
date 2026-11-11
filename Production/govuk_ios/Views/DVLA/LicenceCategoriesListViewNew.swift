import SwiftUI
import Foundation
import Combine

struct RowHighlightButtonStyle: ButtonStyle {
    var showsHighlight: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                showsHighlight && configuration.isPressed
                    ? Color(.systemFill)
                    : Color.clear
            )
            .contentShape(Rectangle())
    }
}

// MARK: - Models

struct EntitlementGroup: Identifiable, Equatable {
    let group: LicenceCategoryGroup
    let entitlements: [Entitlement]

    // Stable identity derived from the group enum
    var id: LicenceCategoryGroup { group }

    var title: String {
        group.title
    }

    var codesDisplay: String {
        entitlements
            .map(\.categoryCode)
            .joined(separator: ", ")
    }
}

struct CategoryLink: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let url: URL
}


// MARK: - Components

// MARK: - Row Component

struct KKEntitlementRowView: View {
    let row: EntitlementGroup
    var showsHighlight: Bool = true
    var onSelect: (() -> Void)?

    var body: some View {
        if let onSelect {
            Button(action: onSelect) {
                rowContent
            }
            .buttonStyle(RowHighlightButtonStyle(showsHighlight: showsHighlight))
        } else {
            rowContent
        }
    }

    private var rowContent: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(row.title)
                .font(.body)
                .foregroundStyle(.primary)

            Spacer(minLength: 16)

            Text(row.codesDisplay)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 4)
    }
}

// MARK: - Section Component

struct EntitlementSectionView: View {
    let title: String
    let items: [EntitlementGroup]
    var showsHighlight: Bool = true
    var onSelectRow: ((EntitlementGroup) -> Void)?

    var body: some View {
        let lastID = items.last?.id

        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
                .padding(.bottom, 8)

            ForEach(items) { row in
                KKEntitlementRowView(
                    row: row,
                    showsHighlight: showsHighlight,
                    onSelect: onSelectRow != nil ? { onSelectRow?(row) } : nil
                )

                if row.id != lastID {
                    Divider()
                        .overlay(Color(.separator).opacity(0.6))
                }
            }
        }
    }
}
struct GoodToKnowSectionView: View {
    let links: [CategoryLink]
    var onLinkClick: ((_ text: String, _ url: URL) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Good to know")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
                .padding(.bottom, 8) // 8pt redline spec

            VStack(alignment: .leading, spacing: 16) {
                Text(
                    """
                    The codes printed on the back of your \
                    driving licence tell you what conditions \
                    you must meet to drive.
                    """
                )

                Text(
                    """
                    Restrictions or requirements may apply \
                    to one or more of these categories. \
                    These are listed on the back of your licence.
                    """
                )
            }
            .font(.body)
            .foregroundStyle(.primary)

            if !links.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(links.enumerated()), id: \.element.id) { index, link in
                        Button {
                            onLinkClick?(link.text, link.url)
                        } label: {
                            HStack {
                                Text(link.text)
                                    .font(.body)
                                    .foregroundStyle(.blue)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                        }
                        .buttonStyle(.plain)

                        if index < links.count - 1 {
                            Divider()
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.top, 48) // 48pt redline spec
            }
        }
    }
}

// MARK: - Reusable List View

struct VMCategoriesListView: View {
    @ObservedObject var viewModel: CategoriesViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 48) {
                if !viewModel.entitledToDrive.isEmpty {
                    EntitlementSectionView(
                        title: "You are entitled to drive",
                        items: viewModel.entitledToDrive,
                        showsHighlight: viewModel.showsRowHighlight,
                        onSelectRow: { row in
                            viewModel.onRowTap(row)
                        }
                    )
                }

                if !viewModel.provisionallyEntitledToDrive.isEmpty {
                    EntitlementSectionView(
                        title: "You can provisionally drive",
                        items: viewModel.provisionallyEntitledToDrive,
                        showsHighlight: viewModel.showsRowHighlight,
                        onSelectRow: { row in
                            viewModel.onRowTap(row)
                        }
                    )
                }

                GoodToKnowSectionView(
                    links: viewModel.links,
                    onLinkClick: { _, url in
                        if let link = viewModel.links.first(where: { $0.url == url }) {
                            viewModel.onLinkClick(link)
                        }
                    }
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
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
        categoryCode: String,
        categoryType: CategoryType,
        categoryLegalLiteral: String = "",
        fromDate: Date = Date(),
        expiryDate: Date = Calendar.current.date(byAdding: .year, value: 10, to: Date()) ?? Date(),
        restrictions: [EntitlementRestriction] = []
    ) -> Entitlement {
        Entitlement(
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

#Preview("Row Taps & Highlight") {
    let viewModel = CategoriesViewModel(
        entitlements: [
            // Full Entitlements
            .preview(categoryCode: "AM", categoryType: .full),
            .preview(categoryCode: "P", categoryType: .full),
            .preview(categoryCode: "Q", categoryType: .full),
            .preview(categoryCode: "A", categoryType: .full),
            .preview(categoryCode: "B", categoryType: .full),
            .preview(categoryCode: "BE", categoryType: .full),

            // Provisional Entitlements
            .preview(categoryCode: "B1", categoryType: .provisional)
        ],
        links: [
            CategoryLink(
                text: "Driving licence categories",
                url: URL(string: "https://www.gov.uk/driving-licence-categories")!
            )
        ],
        showsRowHighlight: true,
        onRowSelected: { selectedGroup in
            print("Selected: \(selectedGroup.title) with codes \(selectedGroup.codesDisplay)")
            print("Underlying entitlements: \(selectedGroup.entitlements)")
        },
        onAnalyticsEvent: { name, params in
            print("Analytics: [\(name)] \(params)")
        }
    )

    VMCategoriesSheetView(viewModel: viewModel)
}
/*
#Preview("Row Taps & Highlight") {
    let viewModel = CategoriesViewModel(
        entitledToDrive: [
            "Mopeds, AM, p, q",
            "Motorcycles, A",
            "Cars, B",
            "Trailers, BE, C1E, D1E"
        ],
        provisionallyEntitledToDrive: [
            "Light vehicles and quad bikes, B1"
        ],
        links: [
            CategoryLink(
                text: "Driving licence categories",
                url: URL(string: "https://www.gov.uk/driving-licence-categories")!
            )
        ],
        showsRowHighlight: true,
        onRowSelected: { selectedRow in
            print("Selected: \(selectedRow.title) with codes \(selectedRow.codesDisplay)")
        },
        onAnalyticsEvent: { name, params in
            print("Analytics: [\(name)] \(params)")
        }
    )

    VMCategoriesSheetView(viewModel: viewModel)
}
*/
