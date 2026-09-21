import SwiftUI
import GovKitUI

struct CountryOptionsBottomSheet: View {
    @ObservedObject var viewModel: EditCountriesViewModel
    let country: Country
    let notificationsEnabled: Bool
    let isTogglingNotifications: Bool
    let isUnfollowing: Bool
    let toggleError: String?
    let onNotificationsToggle: (Bool) -> Void
    let onUnfollow: () -> Void
    let onClearToggleError: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(UIColor.govUK.text.primary))
                }
                .frame(width: 44, height: 44)

                Spacer()

                Text(country.name)
                    .font(Font.govUK.headlineSemibold)
                    .foregroundColor(Color(UIColor.govUK.text.primary))

                Spacer()

                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(uiColor: .govUK.fills.surfaceModal))

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 16) {
                        Text(String(localized: .Travel.editCountryDetailsGetNotifications))
                            .font(Font.govUK.body)
                            .foregroundColor(Color(UIColor.govUK.text.primary))

                        Spacer()

                        Toggle(
                            "",
                            isOn: $viewModel.selectedCountryNotificationEnabled
                        )
                        .disabled(viewModel.isToggleLoading)
                        .onChange(
                            of: notificationsEnabled
                        ) { _ in
                            onNotificationsToggle(notificationsEnabled)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color(UIColor.govUK.fills.surfaceListAlt))
                    .roundedBorder(borderColor: Color(UIColor.govUK.fills.surfaceListAlt))

                    Button {
                        onUnfollow()
                    } label: {
                        HStack(alignment: .center) {
                            Spacer()
                            Text(String(localized: .Travel.editCountryDetailUnfollowButton))
                                .font(Font.govUK.body)
                                .foregroundColor(Color(UIColor.govUK.text.buttonDestructive))
                                .padding(.vertical, 16)
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isToggleLoading)
                    .opacity(viewModel.isToggleLoading ? 0.6 : 1.0)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.govUK.fills.surfaceListAlt))
                    .roundedBorder(borderColor: Color(UIColor.govUK.fills.surfaceListAlt))
                    .padding(.top, 16)
                    .padding(.bottom, 6)

                    Text(String(localized: .Travel.editCountryDetailUnfollowFooter))
                        .font(Font.govUK.caption1)
                        .foregroundStyle(Color(UIColor.govUK.text.secondary))
                        .padding(.horizontal, 16)
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color(uiColor: .govUK.fills.surfaceModal))
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
