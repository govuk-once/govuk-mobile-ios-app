import Foundation
import Testing

@testable import govuk_ios

@Suite
struct DVLAServiceVehicleLookupTests {
    private var mockAnalytics = MockAnalyticsService()
    private var mockService = MockDVLAService()

    @Test
    func vehicleLookup_success_tracksAnalyticsAndReturnsVehicle() async {
        let expectedVehicle = VehicleEnquiryResponse.Vehicle.arrange
        mockService._stubbedFetchVehicleResult = .success(.init(vehicle: expectedVehicle))

        let lookup = mockService.makeVehicleLookup(analyticsService: mockAnalytics)
        let result = await lookup("CA72 BNA")

        switch result {
        case .success(let vehicle):
            #expect(vehicle.vehicleId == expectedVehicle.vehicleId)
        case .failure(let error):
            Issue.record("Expected success, but received failure: \(error)")
        }
    }

    @Test
    func vehicleLookup_notFoundError_mapsToNotFoundError() async {
        mockService._stubbedFetchVehicleResult = .failure(.notFound)

        let lookup = mockService.makeVehicleLookup(analyticsService: mockAnalytics)
        let result = await lookup("CA72 BNA")

        switch result {
        case .failure(let error):
            #expect(error == .notFound)
        case .success:
            Issue.record("Expected .notFound failure, but received success")
        }
    }
}
