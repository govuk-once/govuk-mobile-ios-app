import Testing
import UIKit

@testable import govuk_ios

@Suite
@MainActor
struct LoadingUIButtonTests {
    private let defaultViewModel = LoadingUIButton.ButtonViewModel(
        title: "Submit",
        action: {},
        loadingAccessibilityLabel: "Loading"
    )

    private let defaultConfiguration = LoadingUIButton.ButtonConfiguration(
        textColor: .white,
        backgroundColor: .blue,
        focusedTextColor: .black,
        focusedBackgroundColor: .white
    )

    private func makeSUT(
        viewModel: LoadingUIButton.ButtonViewModel? = nil,
        configuration: LoadingUIButton.ButtonConfiguration? = nil
    ) -> LoadingUIButton {
        LoadingUIButton(
            viewModel: viewModel ?? defaultViewModel,
            configuration: configuration ?? defaultConfiguration
        )
    }

    private func spinner(in button: LoadingUIButton) -> UIActivityIndicatorView? {
        button.subviews.compactMap { $0 as? UIActivityIndicatorView }.first
    }

    // MARK: - Loading state

    @Test
    func isLoading_showsSpinnerAndHidesTitle() {
        let sut = makeSUT()

        sut.viewModel = LoadingUIButton.ButtonViewModel(
            title: "Submit",
            action: {},
            isLoading: true,
            loadingAccessibilityLabel: "Loading"
        )

        #expect(spinner(in: sut)?.isAnimating == true)
        #expect(sut.titleLabel?.alpha == 0)
    }

    @Test
    func isNotLoading_hidesSpinnerAndShowsTitle() {
        let sut = makeSUT()

        sut.viewModel = LoadingUIButton.ButtonViewModel(
            title: "Submit",
            action: {},
            isLoading: true,
            loadingAccessibilityLabel: "Loading"
        )
        sut.viewModel = LoadingUIButton.ButtonViewModel(
            title: "Submit",
            action: {},
            isLoading: false,
            loadingAccessibilityLabel: "Loading"
        )

        #expect(spinner(in: sut)?.isAnimating == false)
        #expect(sut.titleLabel?.alpha == 1)
    }

    // MARK: - Interaction

    @Test
    func isLoading_disablesInteraction() {
        let sut = makeSUT()

        sut.viewModel = LoadingUIButton.ButtonViewModel(
            title: "Submit",
            action: {},
            isLoading: true,
            loadingAccessibilityLabel: "Loading"
        )

        #expect(sut.isUserInteractionEnabled == false)
    }

    @Test
    func isNotLoading_enablesInteraction() {
        let sut = makeSUT()

        #expect(sut.isUserInteractionEnabled == true)
    }

    // MARK: - Accessibility label

    @Test
    func isLoading_setsLoadingAccessibilityLabel() {
        let sut = makeSUT()

        sut.viewModel = LoadingUIButton.ButtonViewModel(
            title: "Submit",
            action: {},
            isLoading: true,
            loadingAccessibilityLabel: "Loading"
        )

        #expect(sut.accessibilityLabel == "Loading")
    }

    @Test
    func isNotLoading_setsTitleAsAccessibilityLabel() {
        let sut = makeSUT()

        sut.viewModel = LoadingUIButton.ButtonViewModel(
            title: "Submit",
            action: {},
            isLoading: true,
            loadingAccessibilityLabel: "Loading"
        )
        sut.viewModel = LoadingUIButton.ButtonViewModel(
            title: "Submit",
            action: {},
            isLoading: false,
            loadingAccessibilityLabel: "Loading"
        )

        #expect(sut.accessibilityLabel == "Submit")
    }

    // MARK: - Accessibility focus colors

    @Test
    func accessibilityElementDidBecomeFocused_appliesFocusedColors() {
        let sut = makeSUT()

        sut.accessibilityElementDidBecomeFocused()

        #expect(sut.configuration?.baseForegroundColor == .black)
        #expect(sut.configuration?.background.backgroundColor == .white)
    }

    @Test
    func accessibilityElementDidLoseFocus_appliesNormalColors() {
        let sut = makeSUT()

        sut.accessibilityElementDidBecomeFocused()
        sut.accessibilityElementDidLoseFocus()

        #expect(sut.configuration?.baseForegroundColor == .white)
        #expect(sut.configuration?.background.backgroundColor == .blue)
    }
}
