import Foundation

extension DrivingLicence {
    static var arrange: DrivingLicence {
        arrange()
    }

    static func arrange(
        licenceType: String = "Full",
        licenceNumber: String = "DECER607085K99AE",
        driverTitle: String? = "MR",
        driverFirstNames: String? = "KENNETH",
        driverLastName: String = "DECERQUEIRA",
        driverFullAddress: String? = "75 ST JOHN'S STREET\nGATESHEAD\nNE8 2ED",
        tokenValidToDate: Date? = .arrange("01/01/1970"),
        licenceStatus: DrivingLicenceStatus = .valid,
        entitlements: [Entitlement] = [.arrange]
    ) -> DrivingLicence {
        .init(
            licenceType: licenceType,
            licenceNumber: licenceNumber,
            driverTitle: driverTitle,
            driverFirstNames: driverFirstNames,
            driverLastName: driverLastName,
            driverFullAddress: driverFullAddress,
            tokenValidToDate: tokenValidToDate,
            licenceStatus: licenceStatus,
            entitlements: entitlements
        )
    }
}

extension Entitlement {
    static var arrange: Entitlement {
        arrange()
    }

    static func arrange(
        categoryCode: String = "B",
        categoryLegalLiteral: String = """
            Vehicles up to 3,500 kg Maximum Authorised Mass (MAM) with up to 8 passenger seats and driver (with a trailer up to 750 kg).       
            """,
        categoryType: CategoryType = .full,
        fromDate: Date = .arrange("09/05/1975"),
        expiryDate: Date = .arrange("15/06/2050"),
        restrictions: [EntitlementRestriction] = [.arrange]
    ) -> Entitlement {
        .init(
            categoryCode: categoryCode,
            categoryLegalLiteral: categoryLegalLiteral,
            categoryType: categoryType,
            fromDate: fromDate,
            expiryDate: expiryDate,
            restrictions: restrictions
        )
    }
}

extension EntitlementRestriction {
    static var arrange: EntitlementRestriction {
        arrange()
    }

    static func arrange(
        restrictionCode: String = "101",
        restrictionLiteral: String = "Not for Hire or reward"
    ) -> EntitlementRestriction {
        .init(
            restrictionCode: restrictionCode,
            restrictionLiteral: restrictionLiteral
        )
    }
}
