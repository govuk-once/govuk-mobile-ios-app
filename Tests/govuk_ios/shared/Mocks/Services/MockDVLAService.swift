import Foundation

@testable import govuk_ios

class MockDVLAService: DVLAServiceInterface {
    var _fetchCustomerVehiclesCallCount = 0
    var _fetchCustomerVehiclesCalledContinuation: CheckedContinuation<Void, Never>?
    var _stubbedCustomerVehiclesResult: CustomerVehiclesResult?
    func fetchCustomerVehicles() async -> CustomerVehiclesResult {
        _fetchCustomerVehiclesCallCount += 1
        _fetchCustomerVehiclesCalledContinuation?.resume()
        return _stubbedCustomerVehiclesResult!
    }
    
    var _fetchCustomerVehicleDetailsCallCount = 0
    var _fetchCustomerVehicleDetailsCalledContinuation: CheckedContinuation<Void, Never>?
    var _stubbedCustomerVehicleDetailsResult: CustomerVehicleDetailsResult?
    func fetchCustomerVehicleDetails(_ vehicleId: Int) async -> CustomerVehicleDetailsResult {
        _fetchCustomerVehicleDetailsCallCount += 1
        _fetchCustomerVehicleDetailsCalledContinuation?.resume()
        return _stubbedCustomerVehicleDetailsResult!
    }

    var _fetchDrivingLicenceCallCount = 0
    var _fetchDrivingLicenceCalledContinuation: CheckedContinuation<Void, Never>?
    var _stubbedFetchDrivingLicenceResult: DrivingLicenceResult?
    func fetchDrivingLicence() async -> DrivingLicenceResult {
        _fetchDrivingLicenceCallCount += 1
        _fetchDrivingLicenceCalledContinuation?.resume()
        return _stubbedFetchDrivingLicenceResult!
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
