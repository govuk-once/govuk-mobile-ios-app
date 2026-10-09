import SwiftUI
import GovKit

struct VehicleCheckSectionView: View {
//  let viewModel: VehicleCheckSectionViewModel

    let searchButtonTitle: LocalizedStringKey
    let onSubmit: (String) -> Void

    @State private var isShowingSheet = false
    @State private var numberPlate = ""
    var body: some View {
        VStack(spacing: 8) {
            Group {
                Title(.DVLA.vehicleCheckTitle)
                Subtitle(.DVLA.vehicleCheckSubtitle)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                isShowingSheet.toggle()
            } label: {
                SearchButtonLabel(text: searchButtonTitle)
            }
            .padding(.top, 8)
        }
        .overlay(alignment: .bottom) {
            if isShowingSheet {
                VehiclePlateOverlayView(
                    isShowingSheet: $isShowingSheet,
                    numberPlate: $numberPlate,
                    action: onSubmit
//                    action: { plate in
//                        print(plate)
//                        // viewModel.action(plate)
//                    }
                )
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isShowingSheet)
    }
}

private struct Title: View {
    let text: LocalizedStringResource

    init(_ text: LocalizedStringResource) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.govUK.title3.bold())
            .foregroundColor(Color(UIColor.govUK.text.primary))
            .accessibilityAddTraits(.isHeader)
    }
}

private struct Subtitle: View {
    let text: LocalizedStringResource

    init(_ text: LocalizedStringResource) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .accessibilityLabel(.DVLA.vehicleCheckSubtitleAccessibilityLabel)
            .font(.govUK.subheadline)
            .foregroundColor(Color(UIColor.govUK.text.primary))
    }
}


private struct SearchButtonLabel: View {
    let text: LocalizedStringKey
    var body: some View {
        HStack(spacing: 8) {
            Text(text)
                .foregroundStyle(Color(uiColor: .govUK.text.primary))
                .multilineTextAlignment(.leading)
            Spacer()
            RegistrationPlateSymbol()
            MagnifyingGlassImage()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(uiColor: .govUK.fills.surfaceList))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct RegistrationPlateSymbol: View {
    var body: some View {
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
    }
}

private struct MagnifyingGlassImage: View {
    var body: some View {
        Image(systemName: "magnifyingglass")
            .font(.system(size: 15, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(Color(uiColor: .primaryBlue), in: Circle())
    }
}

#Preview("SearchButtonLabel") {
    SearchButtonLabel(text: "Some label text")
}

#Preview("RegistrationPlateSymbol") {
    RegistrationPlateSymbol()
}

#Preview("MagnifyingGlassImage") {
    MagnifyingGlassImage()
}

#Preview {
    VehicleCheckSectionView(searchButtonTitle: "Search for a vehicle") { plate in
        print("submitted: \(plate)")
    }
//    VStack {
//        Text("Hello")
//    }
}
