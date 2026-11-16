import SwiftUI
import GovKit

/// A styled GOV.UK text view with consistent typography and accessibility traits.
public protocol GovTextView: View {
    /// The underlying unstyled text content.
    var baseText: Text { get }

    /// The font applied to the text.
    static var font: Font { get }

    /// A Boolean value indicating whether the view carries the `.isHeader` accessibility trait.
    static var isHeader: Bool { get }

    /// Creates a styled text view from an existing `Text` instance.
    init(baseText: Text)
}

extension GovTextView {
    /// Creates a text view that displays localized content identified by a key.
    public init(
        _ key: LocalizedStringKey,
        tableName: String? = nil,
        bundle: Bundle? = nil,
        comment: StaticString? = nil
    ) {
        self.init(baseText: Text(key, tableName: tableName, bundle: bundle, comment: comment))
    }

    /// Creates a text view that displays a localized string resource.
    public init(_ resource: LocalizedStringResource) {
        self.init(baseText: Text(resource))
    }

    /// Creates a text view that displays a string literal without localization.
    public init(verbatim content: String) {
        self.init(baseText: Text(verbatim: content))
    }

    /// Creates a text view that displays a stored string without localization.
    @_disfavoredOverload
    public init<S: StringProtocol>(_ content: S) {
        self.init(baseText: Text(content))
    }

    /// The styled `Text` instance. Use only when a concrete `Text` is required (e.g. inline `Text` interpolation).
    public var rawText: Text {
        baseText.font(Self.font)
    }

    public var body: some View {
        rawText
            .accessibilityAddTraits(Self.isHeader ? .isHeader : [])
    }
}

/// A primary page header styled with `.govUK.title1Bold` and marked as an accessibility header.
public struct HeaderText: GovTextView {
    public let baseText: Text
    public init(baseText: Text) { self.baseText = baseText }
    public static var font: Font { .govUK.title1Bold }
    public static var isHeader: Bool { true }
}

/// A section header styled with `.govUK.title2Bold` and marked as an accessibility header.
public struct SectionHeaderText: GovTextView {
    public let baseText: Text
    public init(baseText: Text) { self.baseText = baseText }
    public static var font: Font { .govUK.title2Bold }
    public static var isHeader: Bool { true }
}

/// A subsection header styled with bold headline typography and marked as an accessibility header.
public struct SubsectionHeaderText: GovTextView {
    public let baseText: Text
    public init(baseText: Text) { self.baseText = baseText }
    public static var font: Font { .headline.weight(.bold) }
    public static var isHeader: Bool { true }
}

/// Standard body copy styled with `.govUK.body`.
public struct BodyText: GovTextView {
    public let baseText: Text
    public init(baseText: Text) { self.baseText = baseText }
    public static var font: Font { .govUK.body }
    public static var isHeader: Bool { false }
}
