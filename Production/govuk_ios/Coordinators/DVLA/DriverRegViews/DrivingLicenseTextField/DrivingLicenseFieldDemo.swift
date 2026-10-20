/*
import SwiftUI

/// Demo harness showing ``PlateFormContent`` in two presentation styles: sheet and custom overlay.
struct DrivingLicenseFieldDemo: View {
    @StateObject private var viewModel: PlateFormViewModel

    /// Mutually exclusive screen state. Computed bindings below bridge each case to SwiftUI's `.sheet(isPresented:)` API.
    enum Presentation {
        case none
        case sheet
        case overlay
        case result(String)
    }

    @State private var presentation: Presentation = .none

    @MainActor
    init(viewModel: PlateFormViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? PlateFormViewModel())
    }

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Spacer()

                Button("Show Sheet") {
                    presentation = .sheet
                }
                .font(.headline)

                Button("Show Overlay") {
                    presentation = .overlay
                }
                .font(.headline)

                Spacer()

                DebugControls(viewModel: viewModel)
                    .padding(.horizontal, 16)
            }

            if case .overlay = presentation {
                overlayPresentation
            }
        }
        .sheet(isPresented: isShowingSheet) {
            PlateFormContent(
                viewModel: viewModel,
                onCancel: { presentation = .none },
                onSubmit: { plate in presentation = .result(plate) }
            )
            .presentationDetents([.medium])
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isOverlayVisible)
        .sheet(isPresented: isShowingResult) {
            if case .result(let plate) = presentation {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    Text(plate)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                    Text("Vehicle found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .presentationDetents([.medium])
            }
        }
    }

    // MARK: - Presentation bindings
    // SwiftUI's .sheet requires a Binding<Bool>. These bridge the enum to that API:
    // the getter pattern-matches the relevant case, the setter resets to .none on dismiss.

    private var isShowingSheet: Binding<Bool> {
        Binding(
            get: { if case .sheet = presentation { return true } else { return false } },
            set: { if !$0 { presentation = .none } }
        )
    }

    private var isShowingResult: Binding<Bool> {
        Binding(
            get: { if case .result = presentation { return true } else { return false } },
            set: { if !$0 { presentation = .none } }
        )
    }

    private var isOverlayVisible: Bool {
        if case .overlay = presentation { return true } else { return false }
    }

    private var overlayPresentation: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { presentation = .none }

            PlateFormContent(
                viewModel: viewModel,
                onCancel: { presentation = .none },
                onSubmit: { plate in presentation = .result(plate) }
            )
            .background(Color(.systemBackground))
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.15), radius: 10)
            .padding(.horizontal, 24)
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
        }
    }
}

private struct DebugControls: View {
    @ObservedObject var viewModel: PlateFormViewModel
    @State private var shouldFail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Test & Debug Controls")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)

            Toggle("Simulate Failure", isOn: $shouldFail)
                .onChange(of: shouldFail) { newValue in
                    viewModel.simulatedError = newValue ? .serviceUnavailable : nil
                }

            Toggle("Clear Error on Any Edit", isOn: Binding(
                get: { viewModel.clearsErrorOnAnyEdit },
                set: { viewModel.clearsErrorOnAnyEdit = $0 }
            ))

            if shouldFail {
                Picker("Error Type", selection: Binding(
                    get: { viewModel.simulatedError ?? .serviceUnavailable },
                    set: { viewModel.simulatedError = $0 }
                )) {
                    ForEach(PlateSubmitError.allCases, id: \.self) { error in
                        Text(error.rawValue).tag(error)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview("DrivingLicenseFieldDemo") {
    DrivingLicenseFieldDemo()
}
*/
