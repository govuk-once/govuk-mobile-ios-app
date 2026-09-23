import Foundation

@testable import govuk_ios

extension ShareCode {
    static var arrange: ShareCode {
        arrange()
    }

    static func arrange(
        state: String = "valid",
        tokenId: String = "token-123",
        token: String = "ABC-123",
        drivingLicenceNumber: String = "BLOGGS123456",
        driverId: String = "test-driver-id",
        documentReference: String = "ABC1234",
        created: Date = Date(timeIntervalSince1970: 0),
        expiry: Date = Date(timeIntervalSince1970: 360),
        status: String? = nil,
        redeemed: Date? = nil,
        cancelled: Date? = nil
    ) -> ShareCode {
        .init(
            state: state,
            tokenId: tokenId,
            token: token,
            drivingLicenceNumber: drivingLicenceNumber,
            driverId: driverId,
            documentReference: documentReference,
            created: created,
            expiry: expiry,
            status: status,
            redeemed: redeemed,
            cancelled: cancelled
        )
    }
}

extension ShareCodeResponse {
    static var arrange: ShareCodeResponse {
        arrange()
    }

    static func arrange(
        shareCode: ShareCode = .arrange
    ) -> ShareCodeResponse {
        .init(
            shareCode: shareCode
        )
    }
}

extension ShareCodeListResponse {
    static var arrange: ShareCodeListResponse {
        arrange()
    }

    static func arrange(
        shareCodes: [ShareCode] = [.arrange, .arrange(state: "cancelled")]
    ) -> ShareCodeListResponse {
        .init(shareCodes: shareCodes)
    }
}

