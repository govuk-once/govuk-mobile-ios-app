import Foundation
import GovKit

extension AppEvent {
    static func searchResultNavigation(item: SearchItem) -> AppEvent {
        navigation(
            text: item.title,
            type: "SearchResult",
            external: true,
            additionalParams: [
                "url": item.link.absoluteString
            ]
        )
    }

    static func searchTerm(
        term: String,
        type: SearchInvocationType,
        section: String? = nil
    ) -> AppEvent {
        let params: [String: Any?] = [
            "text": term,
            "type": type.rawValue,
            "section": section
        ]

        return search(params: params.compactMapValues { $0 })
    }

    private static func search(params: [String: Any]) -> AppEvent {
        .init(
            name: "Search",
            params: params
        )
    }
}
