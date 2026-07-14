import Foundation
import UIKit

protocol PasteboardInterface: AnyObject {
    var string: String? { get set }
}

extension UIPasteboard: PasteboardInterface { }
