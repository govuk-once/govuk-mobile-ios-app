import Foundation
import GovKit

struct VehicleCheckSectionViewModel {
    let action: (String) -> Void
    let buttonTitle: String = String(localized: .DVLA.vehicleCheckButtonTitle)
    private let analyticsService: AnalyticsServiceInterface
    init(analyticsService: AnalyticsServiceInterface, action: @escaping (String) -> Void) {
        self.action = action
        self.analyticsService = analyticsService
    }
    func trackNumberPlateCheck() { }
}
