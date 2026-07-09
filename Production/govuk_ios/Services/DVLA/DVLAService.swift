import Foundation

protocol DVLAServiceInterface {
    func fetchDrivingLicence() async -> DrivingLicenceResult
    func fetchCustomerSummary() async -> CustomerSummaryResult
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

    func fetchCustomerSummary() async -> CustomerSummaryResult {
        await serviceClient.fetchCustomerSummary()
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
