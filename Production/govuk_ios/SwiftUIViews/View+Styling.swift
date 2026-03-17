import SwiftUI

extension View {
    func maxWidthMultilineCenter() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .center)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
    }
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
    func headlineSemiboldPrimary() -> some View {
        self
            .font(Font.govUK.headlineSemibold)
            .foregroundColor(Color(UIColor.govUK.text.primary))
    }
    func subheadlineSecondary() -> some View {
        self
            .font(Font.govUK.subheadline)
            .foregroundColor(Color(UIColor.govUK.text.secondary))
    }
    func bodyPrimary() -> some View {
        self
            .font(Font.govUK.body)
            .foregroundColor(Color(UIColor.govUK.text.primary))
    }
    func bodySecondary() -> some View {
        self
            .font(Font.govUK.body)
            .foregroundColor(Color(UIColor.govUK.text.secondary))
    }
}
