import Foundation

@testable import govuk_ios

extension DriverSummary {
    static var arrange: DriverSummary {
        arrange()
    }

    static func arrange(
        firstNames: String = "KENNETH",
        lastName: String = "DECERQUEIRA",
        licenceNo: String = "DECER607085K99AE",
        licenceType: String = "Full",
        licenceStatus: String = "Valid",
        penaltyPoints: Int = 1,
        validFrom: Date = .init(timeIntervalSince1970: 0),
        validTo: Date = .init(timeIntervalSince1970: 30)
    ) -> DriverSummary {
        .init(
            response: .init(
                driver: .init(
                    licenceNo: licenceNo,
                    firstNames: firstNames,
                    lastName: lastName,
                    penaltyPoints: penaltyPoints
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

