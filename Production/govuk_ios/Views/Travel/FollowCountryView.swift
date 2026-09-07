import SwiftUI
import GovKitUI
import GovKit
import UIKit

struct FollowCountryView: View {
    @StateObject var viewModel: FollowCountryViewModel

    init(viewModel: FollowCountryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var searchBarAlignment: Alignment {
        if #available(iOS 26.0, *) {
            return .bottom
        } else {
            return .top
        }
    }

    private var searchBarPadding: CGFloat {
        let isLoaded = if case .loaded = viewModel.viewState { true } else { false }

        return isLoaded ? 60 : 10
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
                    ErrorView(viewModel: createErrorViewModel())
                }
            }
            .padding(.horizontal, viewModel.viewState == .error ? 0 : 16)
        }
        .task {
            await viewModel.viewDidAppear()
        }
        .onAppear {
            viewModel.trackScreen(screen: self)
        }
        .overlay(alignment: searchBarAlignment) {
            if case .loaded = viewModel.viewState {
                SearchBarView(text: $viewModel.searchText)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 0)
                    .background(.clear)
            }
        }
        .navigationTitle(String(localized: .Travel.followACountryTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            closeButton
        }
        .toolbarBackground(Color(.govUK.fills.surfaceModal), for: .navigationBar)
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
                .contentMargins(
                    .top, 10
                )
                .contentMargins(
                    .bottom, searchBarAlignment == .bottom
                    ? 10
                    : geometry.safeAreaInsets.bottom, for: .scrollContent
                )
        } else {
            scrollView
        }
    }

    @ViewBuilder
    var scrollView: some View {
        ScrollView {
            VStack(spacing: 0) {
                if searchBarAlignment == .top {
                    Spacer()
                        .frame(height: searchBarPadding)
                }

                GroupedList(
                    content: viewModel.sections,
                    sectionBackgroundColor: .govUK.fills.surfaceListAlt
                )

                if searchBarAlignment == .bottom {
                    Spacer()
                        .frame(height: searchBarPadding)
                }
            }
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

extension FollowCountryView: TrackableScreen {
    var trackingClass: String { "CountryListScreen" }
    var trackingTitle: String? { "Follow a country" }
    var trackingName: String { "Follow a country" }
}

extension FollowCountryView {
    private func createErrorViewModel() -> ErrorViewModel {
        ErrorViewModel(
            analyticsService: viewModel.analyticsService,
            title: String(localized: .Travel.followACountryErrorTitle),
            subtitle: String(localized: .Travel.followACountryScreenErrorBody),
            systemImageName: "exclamationmark.circle",
            primaryButtonTitle: String(localized: .Travel.followACountryErrorButtonTitle),
            primaryAction: { [weak viewModel] in
                Task {
                    await viewModel?.retryFetchCountryList()
                }
            },
            contentAlignment: .center,
            trackingName: "CountryListErrorScreen"
        )
    }
}
