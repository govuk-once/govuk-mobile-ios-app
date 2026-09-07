import SwiftUI
import GovKitUI
import GovKit
import UIKit

struct CountryListView: View {
    @StateObject var viewModel: CountryListViewModel

    init(viewModel: CountryListViewModel) {
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
                    CountryListLoadingView()
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
        .navigationTitle(String(localized: .Travel.countryListTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            closeButton
        }
        .toolbarBackground(Color(.govUK.fills.surfaceModal), for: .navigationBar)
        .background(Color(.govUK.fills.surfaceModal))
        .alert(
            String(localized: .Travel.countryListAlertTitle),
            isPresented: Binding(
                get: { viewModel.selectedCountry != nil },
                set: { if !$0 { viewModel.selectedCountry = nil } }
            ),
            presenting: viewModel.selectedCountry
        ) { country in
            Button(String(localized: .Travel.countryListAlertContinue)) {
                viewModel.handleCountrySelection(country)
                viewModel.selectedCountry = nil
            }
            Button(String(localized: .Travel.countryListAlertNotNow)) {
                viewModel.selectedCountry = nil
            }
            Button(String(localized: .Travel.countryListAlertCancel), role: .cancel) {
                viewModel.selectedCountry = nil
            }
        } message: { country in
            Text(String(localized: .Travel.countryListAlertDescription1(country.country)))
                + Text("\n\n")
                + Text(String(localized: .Travel.countryListAlertDescription2))
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

struct CountryListLoadingView: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            ProgressView()
                .controlSize(.large)
                .accessibilityLabel(.Travel.countryListScreenLoading)
            Spacer()
        }
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

            Text(String(localized: .Travel.countryListScreenEmptyTitle))
                .font(Font.govUK.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(GOVUKColors.text.primary))
                .padding(.top, 6)

            Spacer()
        }.frame(maxWidth: .infinity)
    }
}

extension CountryListView: TrackableScreen {
    var trackingClass: String { "CountryListScreen" }
    var trackingTitle: String? { "Follow a country" }
    var trackingName: String { "Follow a country" }
}

extension CountryListView {
    private func createErrorViewModel() -> ErrorViewModel {
        ErrorViewModel(
            analyticsService: viewModel.analyticsService,
            title: String(localized: .Travel.countryListScreenErrorTitle),
            subtitle: String(localized: .Travel.countryListScreenErrorBody),
            systemImageName: "exclamationmark.circle",
            primaryButtonTitle: String(localized: .Travel.countryListScreenErrorButtonTitle),
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
