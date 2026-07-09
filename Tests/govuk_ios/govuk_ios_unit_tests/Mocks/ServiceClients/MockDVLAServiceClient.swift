import Foundation

@testable import govuk_ios

class MockDVLAServiceClient: DVLAServiceClientInterface {

    var _stubbedFetchDrivingLicenceResult: DrivingLicenceResult?
    func fetchDrivingLicence() async -> DrivingLicenceResult {
        _stubbedFetchDrivingLicenceResult!
    }

    var _stubbedFetchCustomerSummaryResult: CustomerSummaryResult?
    func fetchCustomerSummary() async -> CustomerSummaryResult {
        _stubbedFetchCustomerSummaryResult!
    }

    var _stubbedFetchVehicleResult: VehicleResult?
    func fetchVehicle(registration: String) async -> VehicleResult {
        _stubbedFetchVehicleResult!
    }

    var _stubbedFetchShareCodesResult: ShareCodesResult?
    func fetchShareCodes() async -> ShareCodesResult {
        _stubbedFetchShareCodesResult!
    }

    var _stubbedCreateShareCodeResult: ShareCodeResult?
    func createShareCode() async -> ShareCodeResult {
        _stubbedCreateShareCodeResult!
    }

    var _stubbedCancelShareCodeResult: ShareCodeResult?
    func cancelShareCode(id: String) async -> ShareCodeResult {
        _stubbedCancelShareCodeResult!
    }
}
