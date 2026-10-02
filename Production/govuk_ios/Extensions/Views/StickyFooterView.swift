import Foundation
import UIKit

class StickyFooterView: UIView {
    private lazy var stackView: UIStackView = {
        let localView = UIStackView()
        localView.translatesAutoresizingMaskIntoConstraints = false
        localView.axis = .vertical
        localView.distribution = .fillEqually
        localView.spacing = 4
        return localView
    }()

    private lazy var divider: UIView = {
        let localView = UIView()
        localView.backgroundColor = UIColor.govUK.strokes.fixedContainer
        localView.translatesAutoresizingMaskIntoConstraints = false
        return localView
    }()

    init() {
        super.init(frame: .zero)
        configureUI()
        configureConstraints()
        setupTraitTracking()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        layoutMargins = .init(all: 16)
        addSubview(divider)
        addSubview(stackView)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(
                equalToConstant: 0.33
            ),
            divider.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            divider.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            divider.topAnchor.constraint(
                equalTo: topAnchor
            ),
            stackView.topAnchor.constraint(
                equalTo: divider.bottomAnchor,
                constant: 16
            ),
            stackView.trailingAnchor.constraint(
                equalTo: layoutMarginsGuide.trailingAnchor
            ),
            stackView.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor
            ),
            stackView.leadingAnchor.constraint(
                equalTo: layoutMarginsGuide.leadingAnchor
            )
        ])
    }

    func addView(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }
    private func setupTraitTracking() {
        updateStackViewAxis(with: traitCollection)
        if #available(iOS 17.0, *) {
            registerForTraitChanges(
                [UITraitVerticalSizeClass.self]
            ) { [weak self] (view: Self, _) in
                self?.updateStackViewAxis(with: view.traitCollection)
            }
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #unavailable(iOS 17.0) {
            if previousTraitCollection?.verticalSizeClass != traitCollection.verticalSizeClass {
                updateStackViewAxis(with: traitCollection)
            }
        }
    }

    private func updateStackViewAxis(with currentTraits: UITraitCollection) {
        stackView.axis = currentTraits.verticalSizeClass == .compact ? .horizontal : .vertical
    }
}
