import Foundation

protocol DVLAServiceInterface {
    func fetchDrivingLicence() async -> DrivingLicenceResult
    func fetchDriverSummary() async -> DriverSummaryResult
    func fetchCustomerSummary() async -> CustomerSummaryResult
}

class DVLAService: DVLAServiceInterface {
    private let serviceClient: DVLAServiceClientInterface

    init(serviceClient: DVLAServiceClientInterface) {
        self.serviceClient = serviceClient
    }

    func fetchDrivingLicence() async -> DrivingLicenceResult {
        await serviceClient.fetchDrivingLicence()
    }

    func fetchDriverSummary() async -> DriverSummaryResult {
        await serviceClient.fetchDriverSummary()
    }

    func fetchCustomerSummary() async -> CustomerSummaryResult {
        await serviceClient.fetchCustomerSummary()
    }
}
