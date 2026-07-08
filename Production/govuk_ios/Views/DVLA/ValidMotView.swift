import SwiftUI

enum VehicleStatus {
    case valid
    case expiring
    case expired
}

struct VehicleStatusCardView: View {
    let motStatus: VehicleStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FH08 PDH")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.yellow)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )

                    Text(headerText)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    Text("ID4")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()
                Button(action: {
                }, label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(Circle())
                })
            }

            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tax")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Valid until 6 August 2026")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            }

            Divider()
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MOT")
                            .font(.headline)
                            .fontWeight(.bold)

                        Text(motSubtext)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()

                    if motStatus == .valid {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                    } else if motStatus == .expired {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.black)
                            .font(.title3)
                    }
                }

                if motStatus == .expiring {
                    expiringTimelineSection
                }
            }

            Divider()
            Button(action: {
            }, label: {
                HStack {
                    Text("Details")
                        .font(.body)
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
            })
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding()
    }

    // MARK: - Extracted Timeline Helper View
    private var expiringTimelineSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    Capsule()
                        .fill(Color.purple)
                        .frame(width: geo.size.width * 0.18, height: 8)

                    Circle()
                        .fill(Color.black)
                        .frame(width: 10, height: 10)
                        .offset(x: (geo.size.width * 0.18) - 1)
                }
            }
            .frame(height: 10)

            Text("5 days left")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.black)

            Text("It can take a couple of days after your MOT for your status to update")
                .font(.footnote)
                .foregroundColor(.gray)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    private var headerText: String {
        switch motStatus {
        case .valid: return "Volkswagen - M.O.T'd"
        case .expiring: return "Volkswagen - M.O.T Expiring"
        case .expired: return "Volkswagen - M.O.T Expired"
        }
    }

    private var motSubtext: String {
        switch motStatus {
        case .valid: return "Valid until 6 August 2026"
        case .expiring: return "Expiring 11 July 2026"
        case .expired: return "Expired 6 June 2026"
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            VehicleStatusCardView(motStatus: .valid)
            VehicleStatusCardView(motStatus: .expiring)
            VehicleStatusCardView(motStatus: .expired)
        }
        .padding(.vertical)
        .background(Color.gray.opacity(0.1))
    }
}
