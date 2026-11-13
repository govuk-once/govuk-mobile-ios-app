import Foundation
import Testing

@testable import govuk_ios

@Suite
struct DrivingLicenceTests {

    // MARK: - DrivingLicenceResponse & DrivingLicence Decoding

    @Test
    func decode_withFullValidPayload_mapsAllPropertiesCorrectly() throws {
        let json = """
        {
            "customerDrivingLicence": {
                "licenceType": "Full",
                "drivingLicenceNumber": "SMITH901015SM9IJ",
                "driverTitle": "MR",
                "driverFirstNames": "JOHN MICHAEL",
                "driverLastName": "SMITH",
                "driverFullAddress": "10 DOWNING STREET, LONDON, SW1A 2AA",
                "tokenValidToDate": "2030-05-15T00:00:00Z",
                "licenceStatus": "Valid",
                "entitlements": [
                    {
                        "categoryCode": "B",
                        "categoryLegalLiteral": "Motor vehicles up to 3,500kg",
                        "categoryType": "Full",
                        "fromDate": "2015-06-01T00:00:00Z",
                        "expiryDate": "2060-01-01T00:00:00Z",
                        "restrictions": [
                            {
                                "restrictionCode": "01",
                                "restrictionLiteral": "Eyesight correction"
                            }
                        ]
                    }
                ]
            }
        }
        """

        let response = try makeDecoder().decode(
            DrivingLicenceResponse.self,
            from: Data(json.utf8)
        )
        let licence = response.customerDrivingLicence

        #expect(licence.licenceType == "Full")
        #expect(licence.licenceNumber == "SMITH901015SM9IJ")
        #expect(licence.driverTitle == "MR")
        #expect(licence.driverFirstNames == "JOHN MICHAEL")
        #expect(licence.driverLastName == "SMITH")
        #expect(licence.driverFullAddress == "10 DOWNING STREET, LONDON, SW1A 2AA")
        #expect(licence.tokenValidToDate == ISO8601DateFormatter().date(from: "2030-05-15T00:00:00Z"))
        #expect(licence.licenceStatus == .valid)

        let entitlement = try #require(licence.entitlements.first)
        #expect(licence.entitlements.count == 1)
        #expect(entitlement.categoryCode == "B")
        #expect(entitlement.categoryLegalLiteral == "Motor vehicles up to 3,500kg")
        #expect(entitlement.categoryType == .full)
        #expect(entitlement.fromDate == ISO8601DateFormatter().date(from: "2015-06-01T00:00:00Z"))
        #expect(entitlement.expiryDate == ISO8601DateFormatter().date(from: "2060-01-01T00:00:00Z"))

        let restriction = try #require(entitlement.restrictions.first)
        #expect(entitlement.restrictions.count == 1)
        #expect(restriction.restrictionCode == "01")
        #expect(restriction.restrictionLiteral == "Eyesight correction")
    }

    @Test
    func decode_withMissingOptionalFields_setsOptionalsToNil() throws {
        let json = """
        {
            "customerDrivingLicence": {
                "licenceType": "Provisional",
                "drivingLicenceNumber": "DOE850101JD9AB",
                "licenceStatus": "Valid",
                "entitlements": []
            }
        }
        """

        let response = try makeDecoder().decode(
            DrivingLicenceResponse.self,
            from: Data(json.utf8)
        )
        let licence = response.customerDrivingLicence

        #expect(licence.licenceType == "Provisional")
        #expect(licence.licenceNumber == "DOE850101JD9AB")
        #expect(licence.driverTitle == nil)
        #expect(licence.driverFirstNames == nil)
        #expect(licence.driverLastName == nil)
        #expect(licence.driverFullAddress == nil)
        #expect(licence.tokenValidToDate == nil)
        #expect(licence.entitlements.isEmpty)
    }

    @Test
    func decode_withMissingRequiredLicenceNumber_throwsDecodingError() {
        let json = """
        {
            "customerDrivingLicence": {
                "licenceType": "Full",
                "licenceStatus": "Valid",
                "entitlements": []
            }
        }
        """

        #expect(throws: DecodingError.self) {
            try makeDecoder().decode(
                DrivingLicenceResponse.self,
                from: Data(json.utf8)
            )
        }
    }

    @Test
    func encode_mapsDrivingLicenceNumberKeyAndOmitsGeneratedIDs() throws {
        let restriction = EntitlementRestriction(
            restrictionCode: "78",
            restrictionLiteral: "Automatic transmission only"
        )
        let entitlement = Entitlement(
            categoryCode: "B",
            categoryLegalLiteral: "Cars",
            categoryType: .full,
            fromDate: Date(timeIntervalSince1970: 1_700_000_000),
            expiryDate: Date(timeIntervalSince1970: 2_000_000_000),
            restrictions: [restriction]
        )
        let licence = DrivingLicence(
            licenceType: "Full",
            licenceNumber: "TEST12345",
            driverTitle: nil,
            driverFirstNames: "JANE",
            driverLastName: "DOE",
            driverFullAddress: nil,
            tokenValidToDate: nil,
            licenceStatus: .valid,
            entitlements: [entitlement]
        )

        let data = try makeEncoder().encode(licence)
        let jsonObject = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        #expect(jsonObject["drivingLicenceNumber"] as? String == "TEST12345")
        #expect(jsonObject["licenceNumber"] == nil)

        let encodedEntitlements = try #require(jsonObject["entitlements"] as? [[String: Any]])
        #expect(encodedEntitlements.first?["id"] == nil)

        let encodedRestrictions = try #require(
            encodedEntitlements.first?["restrictions"] as? [[String: Any]]
        )
        #expect(encodedRestrictions.first?["id"] == nil)
    }

    // MARK: - DrivingLicenceStatus

    @Test(
        arguments: [
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
        ]
    )
    func decodeStatus_withKnownRawValue_mapsToExpectedCase(
        rawValue: String,
        expectedStatus: DrivingLicenceStatus
    ) throws {
        let data = Data("\"\(rawValue)\"".utf8)

        let decoded = try makeDecoder().decode(DrivingLicenceStatus.self, from: data)

        #expect(decoded == expectedStatus)
    }

    @Test(
        arguments: [
            "Suspended",
            "Pending",
            "valid",
            ""
        ]
    )
    func decodeStatus_withUnrecognisedRawValue_fallsBackToUnknown(rawValue: String) throws {
        let data = Data("\"\(rawValue)\"".utf8)

        let decoded = try makeDecoder().decode(DrivingLicenceStatus.self, from: data)

        #expect(decoded == .unknown)
    }

    // MARK: - CategoryType

    @Test(
        arguments: [
            ("Full", CategoryType.full),
            ("Provisional", CategoryType.provisional)
        ]
    )
    func decodeCategoryType_withValidRawValue_mapsToExpectedCase(
        rawValue: String,
        expectedType: CategoryType
    ) throws {
        let data = Data("\"\(rawValue)\"".utf8)

        let decoded = try makeDecoder().decode(CategoryType.self, from: data)

        #expect(decoded == expectedType)
    }

    @Test
    func decodeCategoryType_withInvalidRawValue_throwsDecodingError() {
        let data = Data("\"Invalid\"".utf8)

        #expect(throws: DecodingError.self) {
            try makeDecoder().decode(CategoryType.self, from: data)
        }
    }

    // MARK: - Entitlement & EntitlementRestriction

    @Test
    func decodeEntitlement_assignsUniqueUUIDsWhenIDIsAbsentFromJSON() throws {
        let json = """
        {
            "categoryCode": "B",
            "categoryLegalLiteral": "Motor vehicles",
            "categoryType": "Full",
            "fromDate": "2020-01-01T00:00:00Z",
            "expiryDate": "2030-01-01T00:00:00Z",
            "restrictions": [
                {
                    "restrictionCode": "01",
                    "restrictionLiteral": "Eyesight correction"
                }
            ]
        }
        """

        let first = try makeDecoder().decode(Entitlement.self, from: Data(json.utf8))
        let second = try makeDecoder().decode(Entitlement.self, from: Data(json.utf8))

        #expect(first.id != second.id)
        #expect(first.restrictions.first?.id != second.restrictions.first?.id)
    }

    @Test
    func entitlementGroup_resolvesMatchingGroupForCategoryCode() {
        let knownEntitlement = Entitlement(
            categoryCode: "B",
            categoryLegalLiteral: "Cars",
            categoryType: .full,
            fromDate: Date(),
            expiryDate: Date(),
            restrictions: []
        )
        let unknownEntitlement = Entitlement(
            categoryCode: "UNKNOWN_CODE",
            categoryLegalLiteral: "Unknown",
            categoryType: .full,
            fromDate: Date(),
            expiryDate: Date(),
            restrictions: []
        )

        #expect(knownEntitlement.group == LicenceCategoryGroup.cars)
        #expect(unknownEntitlement.group == nil)
    }

    // MARK: - Helpers

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
