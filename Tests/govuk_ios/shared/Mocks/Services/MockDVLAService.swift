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

}
