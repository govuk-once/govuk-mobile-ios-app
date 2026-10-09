import SwiftUI
import Foundation

struct VehiclePlateOverlayView: View {
    @Binding var isShowingSheet: Bool
    @Binding var numberPlate: String
    let action: (String) -> Void
    var body: some View {
        VStack(spacing: 0) {
            Text("Enter number plate")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(Color(UIColor.govUK.text.primary))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
                .padding(.bottom, 12)
            HStack(spacing: 8) {
                TextField("", text: $numberPlate)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .textInputAutocapitalization(.characters)
                    .disableAutocorrection(true)
                    .multilineTextAlignment(.center)

            clearInputButton()
                .frame(height: 36)
                .transition(.opacity.combined(with: .scale))
                .opacity(numberPlate.isEmpty ? 0 : 1)
            }
            .padding(.bottom, 12)
            HStack(spacing: 8) {
                Button(
                    action: {
                        isShowingSheet = false
                    },
                    label: {
                        Text("Cancel")
                            .font(.govUK.body)
                            .foregroundColor(Color(UIColor.govUK.text.primary))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color(.grey100))
                            .cornerRadius(12)
                    }
                )
                if !numberPlate.isEmpty {
                    Button(
                        action: {
                            action(numberPlate)
                            isShowingSheet = false
                        },
                        label: {
                            Text("Submit")
                                .font(.govUK.body)
                                .foregroundColor(Color(UIColor.govUK.text.header))
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color(uiColor: .primaryBlue),
                                            in: RoundedRectangle(cornerRadius: 12))
                        }
                    )
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .padding(.bottom, 16)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: numberPlate.isEmpty)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.15), radius: 10)
    }
}

extension VehiclePlateOverlayView {
    @ViewBuilder
    func clearInputButton() -> some View {
        Button {
            numberPlate = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(Color(UIColor.govUK.text.primary))
        }
    }
}

struct VehiclePlateOverlayViewContainer: View {
    @State private var isShowingSheet = false
    @State private var numberPlate = ""
    var body: some View {
        VStack {
            Text("Container")
            Button("Show It") { isShowingSheet.toggle() }
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .bottom) {
            if isShowingSheet {
                VehiclePlateOverlayView(
                    isShowingSheet: $isShowingSheet,
                    numberPlate: $numberPlate,
                    action: { plate in print(plate) }
                )
                .padding(.horizontal)
                .transition(
                    .move(edge: .bottom)
                    .combined(with: .opacity)
                )
            }
        }
        .animation(
            .spring(response: 0.35, dampingFraction: 0.8),
            value: isShowingSheet
        )
    }
}

#Preview {
    VehiclePlateOverlayViewContainer()
}
