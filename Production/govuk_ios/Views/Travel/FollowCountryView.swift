import SwiftUI

struct FollowCountryView: View {
    private var viewModel: FollowCountryViewModel

    init(viewModel: FollowCountryViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                modifiedScrollView(geometry: geometry)
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .navigationTitle(String(localized: .Travel.followACountryTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                closeButton
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .background(Color(.govUK.fills.surfaceModal))
        }
    }

    private var closeButton: some ToolbarContent {
        ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
            Button {
                viewModel.dismissAction()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(Color(uiColor: .govUK.text.primary))
            }
        }
    }

    @ViewBuilder
    func modifiedScrollView(geometry: GeometryProxy) -> some View {
        if #available(iOS 17.0, *) {
            scrollView
                .contentMargins(.bottom, geometry.safeAreaInsets.bottom, for: .scrollContent)
        } else {
            scrollView
        }
    }

    @ViewBuilder
    var scrollView: some View {
        ScrollView {
            Text(String.topics.localized("Placeholder"))
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 12)
                .padding(.top, 10)
        }
    }
}
