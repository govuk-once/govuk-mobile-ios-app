import SwiftUI

extension View {
    func maxWidthMultilineLeading() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
    }
    func title3SemiboldPrimary() -> some View {
        self
            .font(Font.govUK.title3Semibold)
            .foregroundColor(Color(UIColor.govUK.text.primary))
    }
    func bodyPrimary() -> some View {
        self
            .font(Font.govUK.body)
            .foregroundColor(Color(UIColor.govUK.text.primary))
    }
}
