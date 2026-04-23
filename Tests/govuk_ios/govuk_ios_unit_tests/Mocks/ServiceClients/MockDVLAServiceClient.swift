import Foundation

@testable import govuk_ios

class MockDVLAServiceClient: DVLAServiceClientInterface {

    var _stubbedFetchDrivingLicenceResult: DrivingLicenceResult?
    func fetchDrivingLicence() async -> DrivingLicenceResult {
        return _stubbedFetchDrivingLicenceResult!
    }

    var _stubbedFetchDriverSummaryResult: DriverSummaryResult?
    func fetchDriverSummary() async -> DriverSummaryResult {
        return _stubbedFetchDriverSummaryResult!
    }
}
