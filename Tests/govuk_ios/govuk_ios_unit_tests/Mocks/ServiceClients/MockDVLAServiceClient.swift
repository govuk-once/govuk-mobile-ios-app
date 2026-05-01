import Foundation

@testable import govuk_ios

class MockDVLAServiceClient: DVLAServiceClientInterface {

    var _stubbedFetchDrivingLicenceResult: DrivingLicenceResult?
    func fetchDrivingLicence() async -> DrivingLicenceResult {
        _stubbedFetchDrivingLicenceResult!
    }

    var _stubbedFetchDriverSummaryResult: DriverSummaryResult?
    func fetchDriverSummary() async -> DriverSummaryResult {
        _stubbedFetchDriverSummaryResult!
    }

    var _stubbedFetchCustomerSummaryResult: CustomerSummaryResult?
    func fetchCustomerSummary() async -> CustomerSummaryResult {
        _stubbedFetchCustomerSummaryResult!
    }
}
