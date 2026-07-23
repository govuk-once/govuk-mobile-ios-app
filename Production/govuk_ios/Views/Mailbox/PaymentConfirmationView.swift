import SwiftUI
import GovKit
import GovKitUI

struct PaymentConfirmationView: View {
    let amount: Int
    let reference: String
    let completionAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 95, height: 95)
                    .foregroundStyle(Color(UIColor.govUK.text.header))
                    .accessibilityHidden(true)

                Text("Payment successful")
                    .font(.govUK.largeTitleBold)
                    .foregroundStyle(Color(UIColor.govUK.text.header))
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 32)

            VStack(spacing: 12) {
                summaryRow(label: "Amount", value: formattedAmount)
                summaryRow(label: "Vehicle", value: reference)
                summaryRow(label: "Description", value: "Vehicle tax")
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(uiColor: .govUK.fills.surfaceCardDefault))
            )

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .safeAreaInset(edge: .bottom) {
            Button {
                completionAction()
            } label: {
                HStack {
                    Spacer()
                    Text("Done")
                        .font(Font.govUK.bodySemibold)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(
                    Color(uiColor: .govUK.fills.surfaceButtonPrimary)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(16)
            .background(
                Color(uiColor: .govUK.fills.surfaceBackground)
            )
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(Font.govUK.body)
                .foregroundStyle(Color(uiColor: .govUK.text.secondary))
            Spacer()
            Text(value)
                .font(Font.govUK.bodySemibold)
                .foregroundStyle(Color(uiColor: .govUK.text.primary))
        }
    }

    private var formattedAmount: String {
        let pounds = Double(amount) / 100.0
        return String(format: "\u{00A3}%.2f", pounds)
    }
}
