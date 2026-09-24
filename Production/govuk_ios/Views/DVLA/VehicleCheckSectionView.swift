import SwiftUI
import GovKit

struct VehicleCheckSectionView: View {
    let viewModel: VehicleCheckSectionViewModel
    var body: some View {
        VStack(spacing: 8) {
            Text(.DVLA.vehicleCheckTitle)
                .font(.govUK.title3.bold())
                .foregroundColor(Color(UIColor.govUK.text.primary))
                .accessibilityAddTraits(.isHeader)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(.DVLA.vehicleCheckSubtitle)
                .accessibilityLabel(.DVLA.vehicleCheckSubtitleAccessibilityLabel)
                .font(.govUK.subheadline)
                .foregroundColor(Color(UIColor.govUK.text.primary))
                .frame(maxWidth: .infinity, alignment: .leading)
            button
                .padding(.top, 8)
        }
    }

    var button: some View {
        Button(
            action: {
                viewModel.action(viewModel.buttonTitle)
            },
            label: {
                HStack(spacing: 8) {
                    Text(viewModel.buttonTitle)
                        .foregroundStyle(Color(uiColor: .govUK.text.primary))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(.DVLA.vehicleRegAbc)
                        .font(.govUK.vehicleRegistrationMarkBody)
                        .foregroundStyle(Color.black)
                        .padding([.horizontal, .top], 8)
                        .padding(.bottom, 5)
                        .background(
                            Color.white,
                            in: RoundedRectangle(cornerRadius: 6)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.black, lineWidth: 1.5)
                        )
                        .accessibilityHidden(true)
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color(uiColor: .primaryBlue), in: Circle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(uiColor: .govUK.fills.surfaceList))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        )
    }
}

#Preview {
    let viewModel = VehicleCheckSectionViewModel(
        action: { buttonTitle in
            print(buttonTitle)
        }
    )
    ZStack {
        Color(uiColor: .govUK.fills.surfaceBackground)
        VehicleCheckSectionView(viewModel: viewModel)
    }
}
