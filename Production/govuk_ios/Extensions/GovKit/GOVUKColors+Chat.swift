import Foundation
import UIKit
import GovKitUI

extension GOVUKColors {
    public struct Fills {
        public static let surfaceChatBlue: UIColor = {
            .init(
                light: .white,
                dark: .blueDarker80
            )
        }()

        public static let surfaceChatAction: UIColor = {
            .init(
                light: .white,
                dark: .blueDarker50
            )
        }()

        public static let surfaceChatAnswer: UIColor = {
            .init(
                light: .white,
                dark: .blueDarker70
            )
        }()

        public static let surfaceChatQuestion: UIColor = {
            .init(
                light: .white.withAlphaComponent(0.5),
                dark: .blueDarker80.withAlphaComponent(0.5)
            )
        }()

        public static let surfaceChatBackground: UIColor = {
            .init(
                light: .blueLighter90,
                dark: .blueDarker80
            )
        }()

        public static let surfaceChatOnboardingListBackground: UIColor = {
            .init(
                light: .blueLighter90,
                dark: .blueDarker70
            )
        }()
    }

    public struct Strokes {
        public static let focusedChatTextBox: UIColor = {
            .init(
                light: .primaryBlue,
                dark: .accentBlue
            )
        }()

        public static let chatAnswer: UIColor = {
            .init(
                light: .clear,
                dark: .blueDarker25
            )
        }()

        public static let chatDivider: UIColor = {
            .init(
                light: .blueLighter80,
                dark: .blueDarker25
            )
        }()

        public static let chatAction: UIColor = {
            .init(
                light: .grey300,
                dark: .blueLighter25
            )
        }()

        public static let chatOnboardingListDivider: UIColor = {
            .init(
                light: .blueLighter80,
                dark: .blueDarker50
            )
        }()
    }

    public struct Text {
        public static let chatTextArea: UIColor = {
            .init(
                light: .grey700,
                dark: .white
            )
        }()
    }
}
