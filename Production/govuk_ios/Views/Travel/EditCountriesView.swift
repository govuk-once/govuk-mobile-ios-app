import Foundation
import SwiftUI
import GovKitUI
import GovKit

struct EditCountriesView: View {
    @StateObject var viewModel: EditCountriesViewModel

    var body: some View {
        VStack(spacing: 16) {
            switch viewModel.viewState {
            case .loading:
                EditCountriesLoadingView()
            case .loaded:
                GeometryReader { geometry in
                    modifiedScrollView(geometry: geometry)
                }
            case .error:
                ErrorView(viewModel: createErrorViewModel())
            }
        }
        .task {
            await viewModel.viewDidAppear()
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
            VStack(spacing: 0) {
                GroupedList(
                    content: viewModel.countriesSection,
                    sectionBackgroundColor: .govUK.fills.surfaceListAlt
                )

                GroupedList(
                    content: viewModel.footerSection,
                    sectionBackgroundColor: .govUK.fills.surfaceListAlt
                )
            }
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
