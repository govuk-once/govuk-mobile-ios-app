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
        .background(Color(uiColor: .govUK.fills.surfaceBackground).ignoresSafeArea())
        .sheet(
            isPresented: $viewModel.isShowingList,
            onDismiss: {
                viewModel.didDismissList()
            }, content: {
                NavigationView {
                    CountryListView(viewModel: viewModel.countryListViewModel)
                }
            }
        )
    }

    private var scrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.description)
                    .foregroundColor(Color(UIColor.govUK.text.primary))
                    .font(Font.govUK.body)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                GroupedList(
                    content: viewModel.countriesSection,
                    sectionBackgroundColor: .govUK.fills.surfaceCardDefault
                )

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
        ZStack {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 86)
        }
        .background(Color(UIColor.govUK.fills.surfaceList))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
    }
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
