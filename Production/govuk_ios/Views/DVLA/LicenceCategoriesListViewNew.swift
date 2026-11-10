import SwiftUI
import Foundation
import Combine

// MARK: - Models

struct EntitlementRow: Identifiable, ExpressibleByStringLiteral {
    let id = UUID()
    let title: String
    private let codes: [String]

    init(title: String, codes: [String]) {
        self.title = title
        self.codes = codes
    }

    init(stringLiteral value: String) {
        let components = value
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        self.title = components.first ?? ""
        self.codes = Array(components.dropFirst().filter { !$0.isEmpty })
    }

    var codesDisplay: String {
        codes.joined(separator: ", ")
    }
}

struct CategoryLink: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let url: URL
}


// MARK: - Components

struct KKEntitlementRowView: View {
    let row: EntitlementRow

    var body: some View {
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
    }
}


struct EntitlementSectionView: View {
    let title: String
    let items: [EntitlementRow]

    var body: some View {
        let lastID = items.last?.id
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
                .padding(.bottom, 8) // 8pt redline spec

            ForEach(items) { row in
                let isLast = row.id == lastID
                KKEntitlementRowView(row: row)

                if !isLast {
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


@MainActor
final class CategoriesViewModel: ObservableObject {
    @Published private(set) var entitledToDrive: [EntitlementRow] = []
    @Published private(set) var provisionallyEntitledToDrive: [EntitlementRow] = []
    @Published private(set) var links: [CategoryLink] = []

    private let onOpenURL: ((URL) -> Void)?
    private let onAnalyticsEvent: ((String, [String: Any]) -> Void)?

    init(
        entitledToDrive: [EntitlementRow] = [],
        provisionallyEntitledToDrive: [EntitlementRow] = [],
        links: [CategoryLink] = [],
        onOpenURL: ((URL) -> Void)? = nil,
        onAnalyticsEvent: ((String, [String: Any]) -> Void)? = nil
    ) {
        self.entitledToDrive = entitledToDrive
        self.provisionallyEntitledToDrive = provisionallyEntitledToDrive
        self.links = links
        self.onOpenURL = onOpenURL
        self.onAnalyticsEvent = onAnalyticsEvent
    }

    func onLinkClick(_ link: CategoryLink) {
        onAnalyticsEvent?("licence_categories_link_tapped", [
            "title": link.text,
            "destination": link.url.absoluteString
        ])

        if let onOpenURL {
            onOpenURL(link.url)
        } else {
            UIApplication.shared.open(link.url)
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
                        items: viewModel.entitledToDrive
                    )
                }

                if !viewModel.provisionallyEntitledToDrive.isEmpty {
                    EntitlementSectionView(
                        title: "You can provisionally drive",
                        items: viewModel.provisionallyEntitledToDrive
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
                .presentationDragIndicator(.visible)
                .presentationDetents([.large])
                .preferredColorScheme(.dark)
        }
    }
}

#Preview("Parent View") {
    DrivingLicenceParentView()
}
