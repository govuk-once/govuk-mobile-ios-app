#if DEBUG
import Foundation

class MockAppVersionProvider: AppVersionProvider {
    var versionNumber: String?
    var buildNumber: String?
}
#endif // DEBUG
