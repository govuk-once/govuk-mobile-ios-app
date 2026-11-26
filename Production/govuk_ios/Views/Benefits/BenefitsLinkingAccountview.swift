import SwiftUI

struct BenefitsLinkingAccountview: View {
    var onDismiss: () -> Void = {}
    var onContinue: () -> Void = {}
    private let backgroundGreen = Color(red: 16 / 255, green: 112 / 255, blue: 70 / 255)
    private let benefitsList = [
        "Attendance allowance",
        "DLA for adults",
        "ESA",
        "IS",
        "JSA",
        "Pension Credit",
        "PIP",
        "State pension payments."
    ]
    var body: some View {
        ZStack {
            backgroundGreen
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.45))
                        .clipShape(Circle())
                }
                .padding(.top, 12)
                Text("Add your benefits and state pension payment information")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .lineSpacing(2)
                    .padding(.top, 36)
                VStack(alignment: .leading, spacing: 6) {
                    Text("You can see information for:")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.white)
                    ForEach(benefitsList, id: \.self) { item in
                        HStack(alignment: .top, spacing: 12) {
                            Text("•")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Text(item)
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 8)
                    }
                }
                .padding(.top, 24)
                Text("We'll take you to your web browser to sign in.")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.top, 24)
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
