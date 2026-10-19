import SwiftUI

struct PlaceholderSearchResultsView: View {
    let searchQuery: String
    let results: [String] // Accepts the array from the closure
    var closeAction: (() -> Void)?
    var searchAction: (() -> Void)?

    var body: some View {
        List {
            Section(header: Text("--Query: \(searchQuery)")) {
                ForEach(results, id: \.self) { item in
                    Text(item)
                }
            }
        }
        .navigationTitle("Search Results")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Leading (Left) side: Close Button
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { onClose() },
                       label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                })
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Contextual Menu Button (Right of Search)
                Menu {
                    Button("Filter Results", action: {
                        // Add filter action here
                    })
                    Button("Sort by Name", action: {
                        // Add sort action here
                    })
                    Divider()
                    Button("Share Query", action: {
                        // Add share action here
                    })
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16, weight: .semibold))
                }

                Button(action: { onSearchTapped() },
                       label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))
                }
                )
            }
        }
    }

    @MainActor
    private func onSearchTapped() {
        if let searchAction = searchAction {
            searchAction()
        }
    }

    @MainActor
    private func onClose() {
        if let closeAction = closeAction {
            closeAction()
        }
    }
}

#Preview {
    NavigationStack {
        PlaceholderSearchResultsView(
            searchQuery: "go f4st",
            results: ["ferrari", "lambo"]
        )
    }
}
