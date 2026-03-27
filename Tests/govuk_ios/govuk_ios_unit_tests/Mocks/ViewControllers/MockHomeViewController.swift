import UIKit
@testable import govuk_ios

class MockHomeViewController: HomeViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var _hasResetState = false
    override func resetState() {
        _hasResetState = true
    }
    
    var _didOpenSearch = false
    override func openSearch() {
        super.openSearch()
        _didOpenSearch = true
    }
    
    var _didEditTopics = false
    override func editTopics() {
        super.editTopics()
        _didEditTopics = true
    }
}
