import Foundation
import SwiftUI

struct VehicleSpecView: View {
    let viewModel: VehicleSpecViewModel
    private static let standardPadding: CGFloat = 16
    // todo: move this to govkit
    private static let surfaceListAlt: UIColor = {
        .init(
            light: .blueTint95,
            dark: .blueShade70
        )
    }()

    var body: some View {
        ViewThatFits(in: .horizontal) {
            horizontalView
            verticalView
        }
    }

    private var verticalView: some View {
        VStack(alignment: .leading, spacing: 0) {
            makeHorizontallyLabeledIcon(
                iconName: "calendar",
                label: viewModel.year
            )
            .accessibilityLabel(viewModel.yearAccessibilityLabel)
            Divider()
            makeHorizontallyLabeledIcon(
                iconName: viewModel.fuelTypeIcon,
                label: viewModel.fuelTypeName
            )
            .accessibilityLabel(viewModel.fuelTypeAccessibilityLabel)
            Divider()
            makeHorizontallyLabeledIcon(
                iconName: "swatchpalette.fill",
                label: viewModel.colour
            )
            .accessibilityLabel(viewModel.colourAccessibilityLabel)
        }
        .fixedSize(horizontal: true, vertical: false)
        .background(Color(uiColor: Self.surfaceListAlt))
        .roundedBorder(borderColor: .clear)
        .padding(Self.standardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func makeHorizontallyLabeledIcon(
        iconName: String,
        label: String
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.govUK.title3)
                .accessibilityHidden(true)
            Text(label)
        }
        .padding(Self.standardPadding)
    }

    private var horizontalView: some View {
        HStack {
            makeVerticallyLabeledIcon(
                iconName: "calendar",
                label: viewModel.year
            )
            .accessibilityLabel(viewModel.yearAccessibilityLabel)
            Divider()
            makeVerticallyLabeledIcon(
                iconName: viewModel.fuelTypeIcon,
                label: viewModel.fuelTypeName
            )
            .accessibilityLabel(viewModel.fuelTypeAccessibilityLabel)
            Divider()
            makeVerticallyLabeledIcon(
                iconName: "swatchpalette.fill",
                label: viewModel.colour
            )
                .accessibilityLabel(viewModel.colourAccessibilityLabel)
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(Color(uiColor: Self.surfaceListAlt))
        .roundedBorder(borderColor: .clear)
        .padding(Self.standardPadding)
    }

    private func makeVerticallyLabeledIcon(
        iconName: String,
        label: String
    ) -> some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.govUK.title1)
                .accessibilityHidden(true)
            Text(label)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(Self.standardPadding)
        .frame(maxWidth: .infinity)
    }
}
