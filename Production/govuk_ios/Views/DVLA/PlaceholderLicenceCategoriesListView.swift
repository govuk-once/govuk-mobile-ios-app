import SwiftUI
// KK NOTE: Delete this file
struct PlaceholderLicenceCategoriesListView: View {
    @ObservedObject var viewModel: LicenceCategoryListViewModel
    @State private var selectedID: UUID?

    var body: some View {
        List(viewModel.entitlements) { entitlement in
            Button {
                selectedID = entitlement.id
                viewModel.handleDidSelect(entitlement: entitlement)
            } label: {
                PlaceholderEntitlementRowView(
                    entitlement: entitlement,
                    isSelected: selectedID == entitlement.id
                )
            }
            .buttonStyle(.plain)
        }
        .navigationTitle("Categories")
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
    }
}

private struct PlaceholderEntitlementRowView: View {
    let entitlement: Entitlement
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(entitlement.categoryCode)
                        .font(.headline)
                        .fontWeight(.bold)

                    PlaceholderCategoryBadge(type: entitlement.categoryType)
                }

                Text(entitlement.categoryLegalLiteral)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text("\(entitlement.fromDate.formatted(date: .abbreviated, time: .omitted)) – \(entitlement.expiryDate.formatted(date: .abbreviated, time: .omitted))")
                }
                .font(.caption)
                .foregroundStyle(.tertiary)

                if !entitlement.restrictions.isEmpty {
                    Text("Codes: " +
                         entitlement.restrictions.map(\.restrictionCode).joined(separator: ", "))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            .quaternary,
                            in: RoundedRectangle(cornerRadius: 4)
                        )
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.tint)
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
    }
}

private struct PlaceholderCategoryBadge: View {
    let type: CategoryType

    private var tintColor: Color {
        switch type {
        case .full: return .green
        case .provisional: return .orange
        }
    }

    var body: some View {
        Text(type.rawValue.uppercased())
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(tintColor.opacity(0.15), in: Capsule())
            .foregroundStyle(tintColor)
    }
}

struct PHLicenceCategoriesListViewContainer: View {
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
            PlaceholderLicenceCategoriesListView(viewModel: viewModel)
        }
    }
}

#Preview {
    PHLicenceCategoriesListViewContainer()
}
