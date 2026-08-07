import Foundation

@testable import govuk_ios

class MockDVLAServiceClient: DVLAServiceClientInterface {
    var _stubbedCustomerVehiclesResult: CustomerVehiclesResult?
    func fetchCustomerVehicles() async -> govuk_ios.CustomerVehiclesResult {
        _stubbedCustomerVehiclesResult!
    }
    
    var _stubbedCustomerVehicleDetailsResult: CustomerVehicleDetailsResult?
    func fetchCustomerVehicleDetails(_ vehicleID: Int) async -> govuk_ios.CustomerVehicleDetailsResult {
        _stubbedCustomerVehicleDetailsResult!
    }
    

    var _stubbedFetchDrivingLicenceResult: DrivingLicenceResult?
    func fetchDrivingLicence() async -> DrivingLicenceResult {
        _stubbedFetchDrivingLicenceResult!
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
