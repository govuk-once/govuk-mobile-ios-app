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
        section: String? = nil,
        extraParams: [String: Any] = [:]
    ) -> AppEvent {
        let baseParams: [String: Any?] = [
            "text": term,
            "type": type.rawValue,
            "section": section
        ]
        var params = baseParams.compactMapValues { $0 }
        params.merge(extraParams) { _, new in new }
        return search(params: params)
    }

    private static func search(params: [String: Any]) -> AppEvent {
        .init(
            name: "Search",
            params: params
        )
    }
}
