import GovKit
import GovKitUI
import SwiftUI

struct NotificationCentreErrorView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "exclamationmark.circle")
                .resizable()
                .frame(width: 32, height: 32)
                .padding(.bottom, 16)
                .accessibilityHidden(true)
                .foregroundStyle(Color(GOVUKColors.text.iconTertiary))
            Text(.NotificationCentre.notificationErrorTitle)
                .padding(.bottom, 8)
                .font(Font.govUK.bodySemibold)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(GOVUKColors.text.primary))
            Text(.NotificationCentre.notificationErrorBody)
                .font(Font.govUK.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(UIColor.govUK.text.primary))
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.top, 32)
    }
}

struct NotificationCentreNoInternetView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "wifi.slash")
                .resizable()
                .frame(width: 32, height: 32)
                .padding(.bottom, 16)
                .accessibilityHidden(true)
                .foregroundStyle(Color(GOVUKColors.text.iconTertiary))
            Text(.NotificationCentre.notificationNoInternetTitle)
                .padding(.bottom, 8)
                .font(Font.govUK.bodySemibold)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(GOVUKColors.text.primary))
            Text(.NotificationCentre.notificationNoInternetBody)
                .font(Font.govUK.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(UIColor.govUK.text.primary))
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.top, 32)
    }
}

#Preview("Error") {
    NotificationCentreErrorView()
}

#Preview("NoInternet") {
    NotificationCentreNoInternetView()
}
