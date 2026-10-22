import SwiftUI
import GovKitUI

struct RegistrationCancelButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .frame(maxWidth: .infinity, idealHeight: 44)
            .padding()
            .background(Color(uiColor: UIColor.govUK.fills.cancelButtonBackground))
            .foregroundColor(
                Color(uiColor: UIColor.govUK.text.primary)
            )
            .cornerRadius(15)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
