import SwiftUI

extension Image {
    static var chatOnboardingImage: some View {
        Image(decorative: "chat_onboarding_info")
            .resizable()
            .scaledToFit()
            .frame(width: 140, height: 140)
            .padding(.bottom, 16)
    }
}
