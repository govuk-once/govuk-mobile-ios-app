import Foundation

extension Data {

    /// Loads a JSON test fixture from the specified bundle.
    /// - Parameters:
    ///   - filename: The name of the JSON file (without the `.json` extension).
    ///   - bundle: The bundle to search within. Defaults to `.unitTest`.
    /// - Returns: The contents of the fixture as `Data`.
    /// - Note: Triggers a fatal error if the file is missing or cannot be read.
    static func loadFixture(_ filename: String,
                            bundle: Bundle = .unitTest) -> Data {
        guard let resourceURL = bundle.url(forResource: filename,
                                           withExtension: "json") else {
            fatalError("❌ Missing file: '\(filename).json' could not be found in the specified bundle: \(bundle.bundleURL.lastPathComponent)")
        }
        do {
            return try Data(contentsOf: resourceURL)
        } catch {
            fatalError("❌ Failed to read test fixture '\(filename).json': \(error)")
        }
    }
}
