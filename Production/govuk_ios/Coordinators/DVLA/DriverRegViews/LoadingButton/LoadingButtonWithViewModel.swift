//
// Demonstrates use of our LoadingButton style with a ViewModel
//

import SwiftUI
import Combine

// MARK: - 1. Domain & Error Types
enum VehicleError: Error, LocalizedError, Hashable {
    case networkFailure
    case serverError(code: Int)
    case timeout

    var errorDescription: String? {
        switch self {
        case .networkFailure:
            return "No internet connection. Please try again."
        case .serverError(let code):
            return "Server returned error \(code)."
        case .timeout:
            return "Request timed out."
        }
    }
}

// MARK: - 2. Mockable Repository Protocol
protocol VehicleRepositoryProtocol {
    func fetchDetails() async throws -> String
}

// Configurable mock for easy testing
final class MockVehicleRepository: VehicleRepositoryProtocol {
    var shouldFail = false
    var simulatedError: VehicleError = .networkFailure
    var delaySeconds: Double = 2.0

    func fetchDetails() async throws -> String {
        try await Task.sleep(for: .seconds(delaySeconds))

        if shouldFail {
            throw simulatedError
        }

        return "VIN: 1FA6P8CF0R5100000 | Model: 2024 Mustang GT"
    }
}

// MARK: - 3. ViewModel
@MainActor
final class LBVehicleDetailViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var vehicleInfo: String?
    @Published var errorMessage: String?

    // Exposed mock repository for test/debug injection
    let repository: MockVehicleRepository

    init(repository: MockVehicleRepository = MockVehicleRepository()) {
        self.repository = repository
    }

    func fetchVehicleDetails() async {
        isLoading = true
        errorMessage = nil
        vehicleInfo = nil

        defer { isLoading = false }

        do {
            vehicleInfo = try await repository.fetchDetails()
        } catch let error as VehicleError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "An unexpected error occurred."
        }
    }
}

// MARK: - 4. Loading Button Style
struct LoadingButtonStyle: ButtonStyle {
    let isLoading: Bool

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
            } else {
                configuration.label
                    .opacity(configuration.isPressed ? 0.7 : 1.0)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isLoading ? Color.blue.opacity(0.6) : Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
        .scaleEffect(configuration.isPressed && !isLoading ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

// MARK: - 5. Main View with Debug Controls
struct LBVehicleDetailView: View {
    @StateObject private var viewModel: LBVehicleDetailViewModel

    @MainActor
    init(viewModel: LBVehicleDetailViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? LBVehicleDetailViewModel())
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Main Display Content
                VStack(spacing: 12) {
                    if let vehicleInfo = viewModel.vehicleInfo {
                        Label(vehicleInfo, systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.headline)
                    } else if let errorMessage = viewModel.errorMessage {
                        Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Tap button to fetch details")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 100)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Loading Button
                Button {
                    Task {
                        await viewModel.fetchVehicleDetails()
                    }
                } label: {
                    Text("Fetch Vehicle Info")
                        .fontWeight(.bold)
                }
                .buttonStyle(LoadingButtonStyle(isLoading: viewModel.isLoading))
                .disabled(viewModel.isLoading)
                .accessibilityLabel(
                    viewModel.isLoading ?
                    "Getting vehicle details" :
                        "Fetch Vehicle Info"
                )

                Spacer()

                // Debug / Iteration Toolbar
                VStack(alignment: .leading, spacing: 12) {
                    Text("🛠️ Test & Debug Controls")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)

                    Toggle("Simulate Failure Mode", isOn: Binding(
                        get: { viewModel.repository.shouldFail },
                        set: { viewModel.repository.shouldFail = $0 }
                    ))

                    if viewModel.repository.shouldFail {
                        Picker("Failure Reason", selection: Binding(
                            get: { viewModel.repository.simulatedError },
                            set: { viewModel.repository.simulatedError = $0 }
                        )) {
                            Text("Network Failure").tag(VehicleError.networkFailure)
                            Text("Server Error 500").tag(VehicleError.serverError(code: 500))
                            Text("Timeout").tag(VehicleError.timeout)
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding()
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(12)
            }
            .padding()
            .navigationTitle("Vehicle Lookup")
        }
    }
}

struct LoadingButtonWithViewModelDemo: View {
    let mockRepo: MockVehicleRepository = MockVehicleRepository()

    init() {
        self.mockRepo.shouldFail = true
        self.mockRepo.simulatedError = .networkFailure
    }

    var body: some View {
        LBVehicleDetailView(viewModel: LBVehicleDetailViewModel(repository: mockRepo))
    }
}

// MARK: - 6. Previews
#Preview("Interactive Debugging") {
    LBVehicleDetailView()
}

#Preview("Failure State Preview") {
    let mockRepo = MockVehicleRepository()
    mockRepo.shouldFail = true
    mockRepo.simulatedError = .networkFailure

    return LBVehicleDetailView(viewModel: LBVehicleDetailViewModel(repository: mockRepo))
}

#Preview("LoadingButtonWithViewModelDemo") {
    LoadingButtonWithViewModelDemo()
}
