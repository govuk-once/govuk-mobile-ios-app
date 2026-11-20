import UIKit

/// A focusable `UIButton` styled with GOV.UK typography that adapts its appearance on focus
/// and displays a centered loading indicator while disabling interaction during async actions.
final class LoadingUIButton: UIButton {
    var viewModel: ButtonViewModel {
        didSet {
            updateLoadingState()
        }
    }
    var buttonConfiguration: ButtonConfiguration {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }
    private let spinnerView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    init(viewModel: ButtonViewModel, configuration: ButtonConfiguration) {
        self.viewModel = viewModel
        self.buttonConfiguration = configuration
        super.init(frame: .zero)
        setupConfiguration()
        titleLabel?.adjustsFontForContentSizeCategory = true
        setupSpinner()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didUpdateFocus(
        in context: UIFocusUpdateContext,
        with coordinator: UIFocusAnimationCoordinator
    ) {
        super.didUpdateFocus(in: context, with: coordinator)
        coordinator.addCoordinatedAnimations({
            self.setNeedsUpdateConfiguration()
        })
    }

    override func updateConfiguration() {
        super.updateConfiguration()
        if accessibilityElementIsFocused() {
            configureAppearance(for: .focused)
        } else {
            configureAppearance()
        }
    }

    private func configureAppearance(for state: UIControl.State? = nil) {
        let localState = state ?? self.state
        let config = buttonConfiguration
        if localState.contains(.focused) {
            configuration?.background.backgroundColor = config.focusedBackgroundColor
            configuration?.baseForegroundColor = config.focusedTextColor
            spinnerView.color = config.focusedTextColor
        } else {
            configuration?.background.backgroundColor = config.backgroundColor
            configuration?.baseForegroundColor = config.textColor
            spinnerView.color = config.textColor
        }
    }

    override func accessibilityElementDidBecomeFocused() {
        super.accessibilityElementDidBecomeFocused()
        configureAppearance(for: .focused)
    }

    override func accessibilityElementDidLoseFocus() {
        super.accessibilityElementDidLoseFocus()
        configureAppearance()
    }

    private func setupConfiguration() {
        var config = UIButton.Configuration.plain()
        config.title = viewModel.title
        config.titleTextAttributesTransformer = .init { attributes in
            var container = attributes
            container.font = UIFont.govUK.body
            return container
        }
        config.contentInsets = .init(
            top: 16,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
        config.cornerStyle = .fixed
        config.background.cornerRadius = 15
        config.titleAlignment = .center
        self.configuration = config
    }

    private func setupSpinner() {
        addSubview(spinnerView)
        NSLayoutConstraint.activate([
            spinnerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinnerView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func updateLoadingState() {
        if viewModel.isLoading {
            spinnerView.startAnimating()
            accessibilityLabel = viewModel.loadingAccessibilityLabel
        } else {
            spinnerView.stopAnimating()
            accessibilityLabel = viewModel.title
        }
        isUserInteractionEnabled = !viewModel.isLoading
        titleLabel?.alpha = viewModel.isLoading ? 0 : 1
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let width = titleLabel?.frame.width else { return }
        titleLabel?.preferredMaxLayoutWidth = width
        recenterLabel()
    }

    // fix for known bug where label is offcentered when layout changes
    private func recenterLabel() {
        if let labelFrame = titleLabel?.frame {
            let newX = (frame.width / 2.0) - (labelFrame.width / 2.0)
            let newFrame = CGRect(
                x: newX,
                y: labelFrame.minY,
                width: labelFrame.width,
                height: labelFrame.height
            )
            titleLabel?.frame = newFrame
        }
    }
}

extension LoadingUIButton {
    struct ButtonViewModel {
        let title: String
        let action: () -> Void
        var isLoading: Bool = false
        let loadingAccessibilityLabel: String
    }

    struct ButtonConfiguration {
        let textColor: UIColor
        let backgroundColor: UIColor
        let focusedTextColor: UIColor
        let focusedBackgroundColor: UIColor
    }
}
