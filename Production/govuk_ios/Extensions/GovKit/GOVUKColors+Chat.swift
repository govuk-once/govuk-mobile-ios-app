import Foundation
import UIKit
import GovKitUI

extension GOVUKColors.Fills {
    public static let surfaceChatAnswer: UIColor = {
        .init(
            light: .white,
            dark: .blueShade70
        )
    }()

    public static let surfaceChatAction: UIColor = {
        .init(
            light: .white,
            dark: .blueShade50
        )
    }()

    public static let surfaceChatQuestion: UIColor = {
        .init(
            light: .blueShade50,
            dark: .primaryBlue
        )
    }()

    public static let surfaceChatBackground: UIColor = {
        .init(
            light: .blueTint90,
            dark: .blueShade80
        )
    }()

    public static let surfaceChatOnboardingListBackground: UIColor = {
        .init(
            light: .blueTint90,
            dark: .blueShade70
        )
    }()
}

extension GOVUKColors.Strokes {
        public static let focusedChatTextBox: UIColor = {
            .init(
                light: .primaryBlue,
                dark: .accentBlue
            )
        }()

        public static let chatAnswer: UIColor = {
            .init(
                light: .clear,
                dark: .blueShade25
            )
        }()

        public static let chatDivider: UIColor = {
            .init(
                light: .blueTint80,
                dark: .blueShade25
            )
        }()

        public static let chatAction: UIColor = {
            .init(
                light: .grey300,
                dark: .blueTint25
            )
        }()

        public static let chatOnboardingListDivider: UIColor = {
            .init(
                light: .blueTint80,
                dark: .blueShade50
            )
        }()
}

extension GOVUKColors.Text {
        public static let chatTextArea: UIColor = {
            .init(
                light: .grey700,
                dark: .white
            )
        }()
}
