import SwiftUI

struct EntitlementRow: Identifiable {
    let id = UUID()
    let title: String
    private let codes: [String]

    var codesDisplay: String {
        codes.joined(separator: ", ")
    }
}

extension EntitlementRow: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        let components = value
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        self.title = components.first ?? ""
        self.codes = Array(components.dropFirst().filter { !$0.isEmpty })
    }
}

struct KKEntitlementRowView: View {
    let row: EntitlementRow

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(row.title)
                .foregroundStyle(.primary)

            Spacer()

            Text(row.codesDisplay)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Section Component
struct EntitlementSectionView: View {
    let title: String
    let items: [EntitlementRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .padding(.bottom, 6)

            ForEach(Array(items.enumerated()), id: \.element.id) { index, row in
                KKEntitlementRowView(row: row)

                if index < items.count - 1 {
                    Divider()
                        .overlay(Color(.separator).opacity(0.6))
                }
            }
        }
    }
}

struct CategoriesListView: View {
    var entitledToDrive: [EntitlementRow] = []
    var provisionallyEntitledToDrive: [EntitlementRow] = []
    var showsHeaderTitle: Bool = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                if showsHeaderTitle {
                    Text("Categories")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.primary)
                }

                if !entitledToDrive.isEmpty {
                    EntitlementSectionView(
                        title: "You are entitled to drive",
                        items: entitledToDrive
                    )
                }

                if !provisionallyEntitledToDrive.isEmpty {
                    EntitlementSectionView(
                        title: "You can provisionally drive",
                        items: provisionallyEntitledToDrive
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

struct CategoriesSheetView: View {
    @Environment(\.dismiss) private var dismiss

    var entitledToDrive: [EntitlementRow]
    var provisionallyEntitledToDrive: [EntitlementRow] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Dismiss Button Bar
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // Reusable List
            CategoriesListView(
                entitledToDrive: entitledToDrive,
                provisionallyEntitledToDrive: provisionallyEntitledToDrive
            )
        }
    }
}


struct LicenceCategoriesListViewNewContainer: View {
    @StateObject var viewModel = LicenceCategoryListViewModel(
        entitlements: [
            Entitlement(
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
        ],
        didSelectAction: { entitlement in
            print("selected entitlement: \(entitlement)")
        },
        dismissAction: {})

    var body: some View {
        NavigationStack {
//          LicenceCategoriesListView(viewModel: viewModel)
            LicenceCategoriesListViewNew()
        }
    }
}

#Preview("CategoriesSheetView") {
    CategoriesSheetView()
}

#Preview("Single Row") {
    KKEntitlementRowView(row: "Trailers, BE, C1E, D1E")
        .padding()
        .preferredColorScheme(.dark)
}

#Preview("Section") {
    EntitlementSectionView(
        title: "You are entitled to drive",
        items: [
            "Mopeds, AM, p, q",
            "Motorcycles, A"
        ]
    )
    .padding()
    .preferredColorScheme(.dark)
}

#Preview {
    LicenceCategoriesListViewNewContainer()
}
