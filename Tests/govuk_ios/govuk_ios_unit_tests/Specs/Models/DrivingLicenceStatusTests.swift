import Foundation
import Testing

@testable import govuk_ios

struct DrivingLicenceStatusTests {
    private let decoder = JSONDecoder()

    private func encoded(_ string: String) -> Data {
        "\"\(string)\"".data(using: .utf8)!
    }

    @Test(arguments: [
        ("Valid", DrivingLicenceStatus.valid),
        ("Disqualified", DrivingLicenceStatus.disqualified),
        ("Revoked", DrivingLicenceStatus.revoked),
        ("Revoked for medical reasons", DrivingLicenceStatus.revokedForMedicalReasons),
        ("Surrendered", DrivingLicenceStatus.surrendered),
        ("Surrendered voluntarily", DrivingLicenceStatus.surrenderedVoluntarily),
        ("Surrendered for medical reasons", DrivingLicenceStatus.surrenderedForMedicalReasons),
        ("Expired", DrivingLicenceStatus.expired),
        ("Exchanged", DrivingLicenceStatus.exchanged),
        ("Refused", DrivingLicenceStatus.refused),
        ("Refused for medical reasons", DrivingLicenceStatus.refusedForMedicalReasons)
    ])
    func decode_knownRawValue_returnsExpectedCase(rawValue: String, expected: DrivingLicenceStatus) throws {
        let result = try decoder.decode(DrivingLicenceStatus.self, from: encoded(rawValue))
        #expect(result == expected)
    }

    @Test
    func decode_unknownRawValue_returnsUnknown() throws {
        let result = try decoder.decode(DrivingLicenceStatus.self, from: encoded("SomeFutureStatus"))
        #expect(result == .unknown)
    }
}
