import SwiftUI

struct StateLabelFourTestView: View {
    @State private var labelContent: StateLabelContent = .normal("Enter number plate")

    var body: some View {
        VStack(spacing: 20) {
            Text("StateLabelContent 4")
                .font(.headline)

            StateLabel(content: labelContent)

            HStack(spacing: 12) {
                Button("Trigger Error") {
                    withAnimation {
                        labelContent = .error("Search not working - try again later")
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Toggle State") {
                    withAnimation {
                        if case .normal = labelContent {
                            labelContent = .error("Search not working - try again later")
                        } else {
                            labelContent = .normal("Enter number plate")
                        }
                    }
                }
                .buttonStyle(.borderedProminent)


                Button("Clear") {
                    withAnimation {
                        labelContent = .normal("Enter number plate")
                    }
                }
                .buttonStyle(.bordered)
                .disabled(labelContent.isError == false)
            }
        }
        .padding()
    }
}

#Preview("StateLabelDemos") {
    StateLabelFourTestView()
}
