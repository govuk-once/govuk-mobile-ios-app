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
        let isEmpty = if case .empty = viewModel.viewState { true } else { false }

        return (isLoaded || isEmpty) ? 60 : 10
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
                case .empty:
                    FollowCountryEmptyView(
                        searchBarAlignment: searchBarAlignment,
                        searchBarPadding: searchBarPadding
                    )
                case .error:
                    FollowCountryErrorView()
                }
            }
            .padding(.horizontal, 16)
        }
        .task {
            await viewModel.viewDidAppear()
        }
        .onAppear {
            viewModel.trackScreen(screen: self)
        }
        .overlay(alignment: searchBarAlignment) {
            switch viewModel.viewState {
            case .loaded, .empty:
                SearchBarView(text: $viewModel.searchText)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 0)
                    .background(.clear)
            default:
                EmptyView()
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
                    .top, searchBarAlignment == .top
                    ? 10
                    : 10, for: .scrollContent
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
                    content: viewModel.filteredSections,
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

private struct FollowCountryEmptyView: View {
    var searchBarAlignment: Alignment
    var searchBarPadding: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            if searchBarAlignment == .top {
                Spacer()
                    .frame(height: searchBarPadding)
            }

            Text(String(localized: .Travel.followACountryEmptyTitle))
                .font(Font.govUK.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(GOVUKColors.text.primary))
                .padding(.top, 6)

            Spacer()
        }.frame(maxWidth: .infinity)
    }
}

extension FollowCountryView: TrackableScreen {
    var trackingTitle: String? { trackingName }
    var trackingName: String { "FollowACountryScreen" }
}
