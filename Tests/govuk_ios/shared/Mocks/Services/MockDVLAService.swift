import Foundation

@testable import govuk_ios

class MockDVLAService: DVLAServiceInterface {

    var _fetchDrivingLicenceCallCount: Int = 0
    var _fetchDrivingLicenceCalledContinuation: CheckedContinuation<Void, Never>?
    var _stubbedFetchDrivingLicenceResult: DrivingLicenceResult?
    func fetchDrivingLicence() async -> DrivingLicenceResult {
        _fetchDrivingLicenceCallCount += 1
        _fetchDrivingLicenceCalledContinuation?.resume()
        return _stubbedFetchDrivingLicenceResult!
    }

    var _fetchDriverSummaryCallCount = 0
    var _fetchDriverSummaryCalledContinuation: CheckedContinuation<Void, Never>?
    var _stubbedFetchDriverSummaryResult: DriverSummaryResult?
    func fetchDriverSummary() async -> DriverSummaryResult {
        _fetchDriverSummaryCallCount += 1
        _fetchDriverSummaryCalledContinuation?.resume()
        return _stubbedFetchDriverSummaryResult!
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
    var _cancelShareCodeCallCount = 0
    var _cancelShareCodeCalledContinuation: CheckedContinuation<Void, Never>?
    func cancelShareCode(id: String) async -> ShareCodeResult {
        _cancelShareCodeCallCount += 1
        _cancelShareCodeCalledContinuation?.resume()
        return _stubbedCancelShareCodeResult!
    }
}
