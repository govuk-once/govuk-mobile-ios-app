import Foundation

protocol DVLAServiceInterface {
    func fetchDrivingLicence() async -> DrivingLicenceResult
    func fetchCustomerVehicles() async -> CustomerVehiclesResult
    func fetchCustomerVehicleDetails(_ vehicleId: Int) async -> CustomerVehicleDetailsResult
    func fetchVehicle(registration: String) async -> VehicleResult
    func fetchShareCodes() async -> ShareCodesResult
    func createShareCode() async -> ShareCodeResult
    func cancelShareCode(id: String) async -> ShareCodeResult
}

class DVLAService: DVLAServiceInterface {
    private let serviceClient: DVLAServiceClientInterface

    init(serviceClient: DVLAServiceClientInterface) {
        self.serviceClient = serviceClient
    }

    func fetchDrivingLicence() async -> DrivingLicenceResult {
        await serviceClient.fetchDrivingLicence()
    }

    func fetchCustomerVehicles() async -> CustomerVehiclesResult {
        await serviceClient.fetchCustomerVehicles()
    }

    func fetchCustomerVehicleDetails(_ vehicleId: Int) async -> CustomerVehicleDetailsResult {
        await serviceClient.fetchCustomerVehicleDetails(vehicleId)
    }

    func fetchVehicle(registration: String) async -> VehicleResult {
        await serviceClient.fetchVehicle(registration: registration)
    }

    func fetchShareCodes() async -> ShareCodesResult {
        await serviceClient.fetchShareCodes()
    }

    func createShareCode() async -> ShareCodeResult {
        await serviceClient.createShareCode()
    }

    func cancelShareCode(id: String) async -> ShareCodeResult {
        await serviceClient.cancelShareCode(id: id)
    }
}
