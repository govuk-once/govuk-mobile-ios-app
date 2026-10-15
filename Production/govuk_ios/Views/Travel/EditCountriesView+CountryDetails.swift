import SwiftUI

// Extracted the CountryDetailsSheet into a modifier due to limits in testing the UI in snapshot tests
struct CountryDetailsSheetModifier: ViewModifier {
    @ObservedObject var viewModel: EditCountriesViewModel
    func body(content: Content) -> some View {
        content
            .sheet(
                isPresented: $viewModel.isShowingCountryDetails,
                content: { countryDetailsContent }
            )
    }

    @ViewBuilder
    private var countryDetailsContent: some View {
        if let selectedCountry = viewModel.selectedCountry {
            CountryOptionsBottomSheet(
                country: selectedCountry.country,
                notificationsEnabled: viewModel.selectedCountryNotificationEnabled,
                isTogglingNotifications: viewModel.isToggleLoading,
                isUnfollowing: viewModel.isUnfollowing,
                onNotificationsToggle: { enabled in
                    Task {
                        await viewModel.requestToggle(
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
            .sheet(
                isPresented: $viewModel.showNotificationsRationale,
                onDismiss: { viewModel.rationaleFlowDidDismiss() },
                content: { rationaleSheetContent }
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

    @ViewBuilder
    private var rationaleSheetContent: some View {
        if let rationaleViewModel = viewModel.createNotificationsRationaleViewModel() {
            NavigationStack {
                NotificationsRationaleView(viewModel: rationaleViewModel)
                    .interactiveDismissDisabled(
                        rationaleViewModel.viewState == .loading
                    )
            }
        }
    }
}
