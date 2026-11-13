import SwiftUI
import GovKit

public protocol GovTextView: View {
    var baseText: Text { get }
    static var font: Font { get }
    static var isHeader: Bool { get }
    init(baseText: Text)
}

extension GovTextView {
    public init(
        _ key: LocalizedStringKey,
        tableName: String? = nil,
        bundle: Bundle? = nil,
        comment: StaticString? = nil
    ) {
        self.init(baseText: Text(key, tableName: tableName, bundle: bundle, comment: comment))
    }

    public init(_ resource: LocalizedStringResource) {
        self.init(baseText: Text(resource))
    }

    public init(verbatim content: String) {
        self.init(baseText: Text(verbatim: content))
    }

    @_disfavoredOverload
    public init<S: StringProtocol>(_ content: S) {
        self.init(baseText: Text(content))
    }

    public var rawText: Text {
        baseText.font(Self.font)
    }

    public var body: some View {
        rawText
            .accessibilityAddTraits(Self.isHeader ? .isHeader : [])
    }
}

public struct HeaderText: GovTextView {
    public let baseText: Text
    public init(baseText: Text) { self.baseText = baseText }
    public static var font: Font { .govUK.title1Bold }
    public static var isHeader: Bool { true }
}

public struct SectionHeaderText: GovTextView {
    public let baseText: Text
    public init(baseText: Text) { self.baseText = baseText }
    public static var font: Font { .govUK.title2Bold }
    public static var isHeader: Bool { true }
}

public struct SubsectionHeaderText: GovTextView {
    public let baseText: Text
    public init(baseText: Text) { self.baseText = baseText }
    public static var font: Font { .headline.weight(.bold) }
    public static var isHeader: Bool { true }
}

public struct BodyText: GovTextView {
    public let baseText: Text
    public init(baseText: Text) { self.baseText = baseText }
    public static var font: Font { .govUK.body }
    public static var isHeader: Bool { false }
}
