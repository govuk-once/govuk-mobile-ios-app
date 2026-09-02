import SwiftUI
import GovKit
import UIKit

struct SearchBarView: UIViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let localSearchBar = UISearchBar()
        localSearchBar.delegate = context.coordinator

        localSearchBar.backgroundColor = .clear
        localSearchBar.barTintColor = .clear
        localSearchBar.isTranslucent = true

        localSearchBar.searchBarStyle = .minimal
        localSearchBar.translatesAutoresizingMaskIntoConstraints = false
        localSearchBar.enablesReturnKeyAutomatically = false

        localSearchBar.searchTextField.backgroundColor = UIColor.govUK.fills.surfaceSearch
        localSearchBar.searchTextField.clearButtonMode = .whileEditing

        configureAppearance(for: localSearchBar)
        colorSearchBarButton()

        return localSearchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        configureAppearance(for: uiView)
    }

    private func configureAppearance(for searchBar: UISearchBar) {
        let primaryTextColor = UIColor.govUK.text.primary
        let secondaryTextColor = UIColor.govUK.text.secondary

        searchBar.searchTextField.defaultTextAttributes = [
            .foregroundColor: primaryTextColor,
            .font: UIFont.govUK.body
        ]

        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: String.search.localized("searchBarPlaceholder"),
            attributes: [
                .foregroundColor: secondaryTextColor,
                .font: UIFont.govUK.body
            ]
        )

        searchBar.searchTextField.tintColor = secondaryTextColor
        searchBar.tintColor = secondaryTextColor
    }

    private func colorSearchBarButton() {
        let searchBarButton = UIBarButtonItem.appearance(
            whenContainedInInstancesOf: [UISearchBar.self]
        )
        searchBarButton.setTitleTextAttributes(
            [.foregroundColor: UIColor.govUK.text.primary],
            for: .normal
        )
    }

    final class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
        }

        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(false, animated: true)
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = ""
            text = ""
            searchBar.resignFirstResponder()
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    }
}
