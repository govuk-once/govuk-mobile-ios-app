import SwiftUI
import GovKit

struct TravelLoadingView: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            ProgressView()
                .controlSize(.large)
                .accessibilityLabel(.Travel.travelAlertsLoading)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TravelLoadingView()
}
