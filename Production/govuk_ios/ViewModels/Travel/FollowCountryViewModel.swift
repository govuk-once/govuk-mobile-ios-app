import Foundation
import GovKitUI
import GovKit

class FollowCountryViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded
        case error
    }

    @Published private(set) var viewState: ViewState = .loading

    private let travelService: TravelServiceInterface
    let dismissAction: () -> Void

    init(
        travelService: TravelServiceInterface,
        dismissAction: @escaping () -> Void
    ) {
        self.travelService = travelService
        self.dismissAction = dismissAction
    }

    @MainActor
    func viewDidAppear() async {
        await fetchCountryList()
    }

    @MainActor
    private func fetchCountryList() async {
        viewState = .loading

        travelService.getCountries(forceRefresh: false) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success:
                    self?.viewState = .loaded
                case .failure:
                    self?.viewState = .error
                }
            }
        }
    }
}
