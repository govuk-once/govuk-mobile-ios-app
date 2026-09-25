import SwiftUI
import GovKitUI
import GovKit
import UIKit

struct CountryListView: View {
    @StateObject var viewModel: CountryListViewModel
    @Environment(\.sizeCategory) var sizeCategory

    private let horizontalPadding: CGFloat = 16
    private let searchBarHorizontalPadding: CGFloat = 14
    private let searchBarBottomPadding: CGFloat = 0
    private let defaultPadding: CGFloat = 10
    private let contentMarginsPadding: CGFloat = 10
    private let loadedSearchBarBasePadding: CGFloat = 60

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
        let basePadding: CGFloat = switch viewModel.viewState {
        case .loaded, .empty:
            loadedSearchBarBasePadding
        default:
            defaultPadding
        }

        return UIFontMetrics.default.scaledValue(for: basePadding)
    }

    var body: some View {
        mainContentView
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
                        .padding(.horizontal, searchBarHorizontalPadding)
                        .padding(.bottom, searchBarBottomPadding)
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
                alertActions(for: country)
            } message: { country in
                alertMessage(for: country)
            }
            .sheet(isPresented: $viewModel.showTravelAlertsPermission) {
                TravelAlertsPermissionView(
                    viewModel: viewModel.createPermissionViewModel()
                )
            }
    }

    @ViewBuilder
    private var mainContentView: some View {
        VStack {
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
        .padding(.horizontal, viewModel.viewState == .error ? 0 : horizontalPadding)
    }

    @ViewBuilder
    private func alertActions(for country: Country) -> some View {
        Button(String(localized: .Travel.countryListAlertContinue)) {
            viewModel.onGetNotificationAlertTap(country)
        }
        Button(String(localized: .Travel.countryListAlertNotNow)) {
            viewModel.onNotNowAlertTap(country)
        }
        Button(String(localized: .Travel.countryListAlertCancel), role: .cancel) {
            viewModel.selectedCountry = nil
        }
    }

    @ViewBuilder
    private func alertMessage(for country: Country) -> some View {
        Text(String(localized: .Travel.countryListAlertDescription1(country.name)))
        + Text("\n\n")
        + Text(String(localized: .Travel.countryListAlertDescription2))
    }

    private var closeButton: some ToolbarContent {
        ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
            Button {
                viewModel.selectedCountry = nil
                viewModel.dismissAction(false)
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
                    .top, contentMarginsPadding
                )
                .contentMargins(
                    .bottom, searchBarAlignment == .bottom
                    ? contentMarginsPadding
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
                .accessibilityLabel(.Travel.travelAlertsLoading)
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
