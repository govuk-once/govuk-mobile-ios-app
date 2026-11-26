import SwiftUI

struct BenefitsAccountConfirmationView: View {
    var onContinue: () -> Void = {}
    private let backgroundGreen = Color(red: 16 / 255, green: 112 / 255, blue: 70 / 255)
    var body: some View {
        ZStack {
            backgroundGreen
                .ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                // Centered Checkmark Icon & Title
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 84, height: 84)
                        Image(systemName: "checkmark")
                            .font(.system(size: 38, weight: .semibold))
                            .foregroundColor(backgroundGreen)
                    }
                    Text("Benefits payment\ninformation linked")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                Spacer()
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.black)
                        .cornerRadius(12)
                }
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 24)
        }
        .preferredColorScheme(.dark)
    }
}
