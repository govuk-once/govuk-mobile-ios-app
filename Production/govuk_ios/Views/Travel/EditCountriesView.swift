import Foundation
import SwiftUI
import GovKitUI
import GovKit

struct EditCountriesView: View {
    @StateObject var viewModel: EditCountriesViewModel

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                EditCountriesLoadingView()
            case .loaded:
                scrollView
            case .error:
                ErrorView(viewModel: createErrorViewModel())
            }
        }
        .task {
            await viewModel.viewDidAppear()
        }
        .onAppear {
            viewModel.trackScreen(screen: self)
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground).ignoresSafeArea())
        .sheet(
            isPresented: $viewModel.isShowingList,
            onDismiss: {
                viewModel.didDismissList(forceRefresh: false)
            }, content: {
                NavigationView {
                    CountryListView(viewModel: viewModel.countryListViewModel)
                }
            }
        )
        .sheet(
            isPresented: $viewModel.isShowingCountryDetails,
            content: {
                if let selectedCountry = viewModel.selectedCountry {
                    CountryOptionsBottomSheet(
                        country: selectedCountry.country,
                        notificationsEnabled: $viewModel.selectedCountryNotificationEnabled,
                        isTogglingNotifications: viewModel.isToggleLoading,
                        isUnfollowing: viewModel.isUnfollowing,
                        onNotificationsToggle: { enabled in
                            Task {
                                await viewModel.toggleNotifications(
                                    slug: selectedCountry.country.slug,
                                    enabled: enabled
                                )
                            }
                        },
                        onUnfollow: {
                            Task {
                                await viewModel.unfollowCountry(
                                    slug: selectedCountry.country.slug,
                                    enabled: viewModel.selectedCountryNotificationEnabled
                                )
                            }
                        },
                        onClearToggleError: {
                            viewModel.clearToggleError()
                        }
                    )
                    .alert(
                        String(localized: .Travel.editCountriesErrorTitle),
                        isPresented: .constant(viewModel.displayToggleError),
                        presenting: viewModel.displayToggleError
                    ) { _ in
                        Button(String(localized: .Travel.editCountriesErrorButton)) {
                            viewModel.clearToggleError()
                        }
                    } message: { _ in
                        Text(String(localized: .Travel.editCountriesErrorDescription))
                    }
                }
            }
        )
        .alert(
            String(localized: .Travel.editCountriesErrorTitle),
            isPresented: .constant(viewModel.displayUnfollowError),
            presenting: viewModel.displayUnfollowError
        ) { _ in
            Button(String(localized: .Travel.editCountriesErrorButton)) {
                viewModel.clearUnfollowError()
            }
        } message: { _ in
            Text(String(localized: .Travel.editCountriesErrorDescription))
        }
    }

    private var scrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.description)
                    .foregroundColor(Color(UIColor.govUK.text.primary))
                    .font(Font.govUK.body)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if !viewModel.countriesSection.isEmpty {
                    GroupedList(
                        content: viewModel.countriesSection,
                        sectionBackgroundColor: .govUK.fills.surfaceCardDefault
                    )
                }

                GroupedList(
                    content: viewModel.footerSection,
                    sectionBackgroundColor: .govUK.fills.surfaceCardDefault
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
}

private struct EditCountriesLoadingView: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            ProgressView()
                .controlSize(.large)
                .accessibilityLabel(.Travel.travelAlertsLoading)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

extension EditCountriesView: TrackableScreen {
    var trackingClass: String { "EditCountriesScreen" }
    var trackingTitle: String? { "Edit countries" }
    var trackingName: String { "Edit countries" }
}

extension EditCountriesView {
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
            trackingName: "EditCountriesErrorScreen"
        )
    }
}
