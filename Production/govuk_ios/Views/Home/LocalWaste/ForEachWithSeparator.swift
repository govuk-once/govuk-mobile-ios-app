//

import SwiftUI

@MainActor
struct ForEachWithSeparator<Data: RandomAccessCollection,
                            ID: Hashable,
                            Content: View,
                            D: View>: View {
    let data: Data
    let id: KeyPath<Data.Element, ID>
    let content: (Data.Element) -> Content
    let separator: (() -> D)

    init(_ data: Data,
         id: KeyPath<Data.Element, ID>,
         content: @escaping (Data.Element) -> Content,
         separator: @escaping () -> D) {
       self.data = data
       self.id = id
       self.content = content
       self.separator = separator
    }

    var body: some View {
        ForEach(data, id: id) { element in
            content(element)

            if element[keyPath: id] != data.last![keyPath: id] {
                separator()
            }
        }
    }
}
