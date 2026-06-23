import Foundation

@testable import govuk_ios

extension DriverSummary {
    static var arrange: DriverSummary {
        arrange()
    }

    static func arrange(
        title: String = "MR",
        firstNames: String = "KENNETH",
        lastName: String = "DECERQUEIRA",
        address: DriverAddress = .arrange,
        licenceNo: String = "DECER607085K99AE",
        licenceType: String = "Full",
        licenceStatus: DrivingLicenceStatus = .valid,
        penaltyPoints: Int = 1,
        validFrom: Date = .init(timeIntervalSince1970: 0),
        validTo: Date = .init(timeIntervalSince1970: 30)
    ) -> DriverSummary {
        .init(
            response: .init(
                driver: .init(
                    licenceNo: licenceNo,
                    title: title,
                    firstNames: firstNames,
                    lastName: lastName,
                    penaltyPoints: penaltyPoints,
                    address: address
                ),
                licence: .init(
                    type: licenceType,
                    status: licenceStatus
                ),
                token: .init(
                    validFromDate: validFrom,
                    validToDate: validTo
                )
            )
        )
    }
}

extension DriverAddress {
    static var arrange: DriverAddress {
        arrange()
    }
    static func arrange(
        line1: String? = "75 ST JOHN'S STREET",
        line2: String? = "GATESHEAD",
        line3: String? = nil,
        line4: String? = nil,
        line5: String? = nil,
        postcode: String? = "NE8 2ED"
    ) -> DriverAddress {
        .init(
            unstructuredAddress: .init(
                line1: line1,
                line2: line2,
                line3: line3,
                line4: line4,
                line5: line5,
                postcode: postcode
            )
        )
    }
}

