import Foundation
import SwiftUI

extension View {
    func applyStyle<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}
