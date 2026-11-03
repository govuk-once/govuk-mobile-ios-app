import SwiftUI
import GovKitUI
import GovKit

struct TravelAlertsWidgetView: View {
    @StateObject var viewModel: TravelAlertsWidgetViewModel

    var body: some View {
        VStack(spacing: 16) {
            Group {
                switch viewModel.viewState {
                case .loading:
                    TravelAlertsLoadingView()
                case let .loaded(rows):
                    TravelAlertsLoadedView(
                        rows: rows,
                        editAction: {
                            viewModel.openEditCountries()
                        }
                    )
                case .empty:
                    let title = String(localized: .Travel.followCountryWidgetTitle)
                    TravelAlertsEmptyView(
                        title: title,
                        description: String(localized: .Travel.followCountryWidgetDescription),
                        onTapAction: {
                            viewModel.onFollowCountryTap(text: title)
                        }
                    )
                case .error:
                    if let errorViewModel = viewModel.errorViewModel {
                        ZStack {
                            AppErrorView(viewModel: errorViewModel)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 16)
                        }
                        .background(Color(UIColor.govUK.fills.surfaceList))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .task {
            await viewModel.viewDidAppear()
        }
        .sheet(
            isPresented: $viewModel.isShowingList,
            onDismiss: {
                viewModel.didDismissList()
            }, content: {
                NavigationView {
                    CountryListView(
                        viewModel: viewModel.countryListViewModel
                    )
                }
            }
        )
        .alert(
            String(localized: .Travel.editCountriesErrorTitle),
            isPresented: $viewModel.isShowingError,
            presenting: viewModel.isShowingError
        ) { _ in
            Button(String(localized: .Travel.editCountriesErrorButton)) {
                viewModel.isShowingError = false
            }
        } message: { _ in
            Text(String(localized: .Travel.editCountriesErrorDescription))
        }
    }
}

private struct TravelAlertsEmptyView: View {
    let title: String
    let description: String
    let onTapAction: () -> Void

    var body: some View {
        IconActionCardView(
            viewModel: IconActionCardViewModel(
                iconName: "plus.circle",
                title: title,
                description: String(localized: .Travel.followCountryWidgetDescription),
                action: onTapAction,
                contentPadding: 24,
                iconBottomPadding: 8
            )
        )
    }
}

private struct TravelAlertsLoadedView: View {
    let rows: [GroupedListSection]
    let editAction: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            SectionHeaderLabelView(model: SectionHeaderLabelViewModel(
                title: String(localized: .Travel.travelAlertLoadedHeading),
                button: .init(
                    localisedTitle: String(localized: .Travel.travelAlertLoadedButtonEdit),
                    action: editAction
                )
            ))

            GroupedList(
                content: rows,
                sectionBackgroundColor: .govUK.fills.surfaceList
            )
        }
    }
}

private struct TravelAlertsLoadingView: View {
    var body: some View {
        ZStack {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 86)
                .accessibilityLabel(.Travel.travelAlertsLoading)
        }
        .background(Color(UIColor.govUK.fills.surfaceList))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
