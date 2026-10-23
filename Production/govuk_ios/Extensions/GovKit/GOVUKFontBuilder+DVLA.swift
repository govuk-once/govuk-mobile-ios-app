import Foundation
import SwiftUI
import GovKitUI

extension GOVUKFontBuilder {
    var vehicleRegistrationMarkBody: Font {
        .custom("DVLA-VRM", size: 18, relativeTo: .body)
    }
    var vehicleRegistrationMarkExtraLarge: Font {
        .custom("DVLA-VRM", size: 56)
    }
    var vehicleRegistrationInputFieldText: Font {
        .custom("DVLA-VRM", size: 48, relativeTo: .body)
    }
}
