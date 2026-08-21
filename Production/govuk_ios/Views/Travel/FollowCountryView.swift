import SwiftUI
import GovKitUI
import GovKit

struct FollowCountryView: View {
    @StateObject var viewModel: FollowCountryViewModel

    init(viewModel: FollowCountryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            Group {
                switch viewModel.viewState {
                case .loading:
                    FollowCountryLoadingView()
                case .loaded:
                    GeometryReader { geometry in
                        modifiedScrollView(geometry: geometry)
                    }
                case .error:
                    FollowCountryErrorView()
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
        }
        .task {
            await viewModel.viewDidAppear()
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
            GroupedList(
                content: viewModel.sections,
                sectionBackgroundColor: .govUK.fills.surfaceListAlt
            )
        }
    }
}

struct FollowCountryLoadingView: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            ProgressView()
                .controlSize(.large)
                .accessibilityLabel(.Travel.followACountryScreenLoading)
            Spacer()
        }
    }
}

struct FollowCountryErrorView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "exclamationmark.circle")
                .resizable()
                .frame(width: 32, height: 32)
                .padding(.bottom, 16)
                .accessibilityHidden(true)
                .foregroundStyle(Color(GOVUKColors.text.iconTertiary))
            Text(.Travel.followACountryErrorTitle)
                .padding(.bottom, 8)
                .font(Font.govUK.bodySemibold)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(GOVUKColors.text.primary))
            Text(.Travel.followACountryScreenErrorBody)
                .font(Font.govUK.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(UIColor.govUK.text.primary))
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.top, 32)
    }
}
