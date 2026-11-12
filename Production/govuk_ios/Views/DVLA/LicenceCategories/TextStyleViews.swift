import SwiftUI
import GovKit

public struct HeaderText: View {
    private let text: Text

    public init(
        _ key: LocalizedStringKey,
        tableName: String? = nil,
        bundle: Bundle? = nil,
        comment: StaticString? = nil
    ) {
        self.text = Text(key, tableName: tableName, bundle: bundle, comment: comment)
    }

    public init(_ resource: LocalizedStringResource) {
        self.text = Text(resource)
    }

    public init(verbatim content: String) {
        self.text = Text(verbatim: content)
    }

    @_disfavoredOverload
    public init<S: StringProtocol>(_ content: S) {
        self.text = Text(content)
    }

    /// Use only when a concrete `Text` is required (e.g. inline `Text` interpolation).
    public var rawText: Text {
        text.font(.govUK.title1Bold)
    }

    public var body: some View {
        rawText
            .accessibilityAddTraits(.isHeader)
    }
}

public struct SectionHeaderText: View {
    private let text: Text

    public init(
        _ key: LocalizedStringKey,
        tableName: String? = nil,
        bundle: Bundle? = nil,
        comment: StaticString? = nil
    ) {
        self.text = Text(key, tableName: tableName, bundle: bundle, comment: comment)
    }

    public init(_ resource: LocalizedStringResource) {
        self.text = Text(resource)
    }

    public init(verbatim content: String) {
        self.text = Text(verbatim: content)
    }

    @_disfavoredOverload
    public init<S: StringProtocol>(_ content: S) {
        self.text = Text(content)
    }

    /// Use only when a concrete `Text` is required (e.g. inline `Text` interpolation).
    public var rawText: Text {
        text.font(.govUK.title2Bold)
    }

    public var body: some View {
        rawText
            .accessibilityAddTraits(.isHeader)
    }
}

public struct SubsectionHeaderText: View {
    private let text: Text

    public init(
        _ key: LocalizedStringKey,
        tableName: String? = nil,
        bundle: Bundle? = nil,
        comment: StaticString? = nil
    ) {
        self.text = Text(key, tableName: tableName, bundle: bundle, comment: comment)
    }

    public init(_ resource: LocalizedStringResource) {
        self.text = Text(resource)
    }

    public init(verbatim content: String) {
        self.text = Text(verbatim: content)
    }

    @_disfavoredOverload
    public init<S: StringProtocol>(_ content: S) {
        self.text = Text(content)
    }

    /// Use only when a concrete `Text` is required (e.g. inline `Text` interpolation).
    public var rawText: Text {
        text.font(.headline.weight(.bold))
    }

    public var body: some View {
        rawText
            .accessibilityAddTraits(.isHeader)
    }
}

public struct BodyText: View {
    private let text: Text

    public init(
        _ key: LocalizedStringKey,
        tableName: String? = nil,
        bundle: Bundle? = nil,
        comment: StaticString? = nil
    ) {
        self.text = Text(key, tableName: tableName, bundle: bundle, comment: comment)
    }

    public init(_ resource: LocalizedStringResource) {
        self.text = Text(resource)
    }

    public init(verbatim content: String) {
        self.text = Text(verbatim: content)
    }

    @_disfavoredOverload
    public init<S: StringProtocol>(_ content: S) {
        self.text = Text(content)
    }

    /// Use only when a concrete `Text` is required (e.g. inline `Text` interpolation).
    public var rawText: Text {
        text.font(.govUK.body)
    }

    public var body: some View {
        rawText
    }
}
