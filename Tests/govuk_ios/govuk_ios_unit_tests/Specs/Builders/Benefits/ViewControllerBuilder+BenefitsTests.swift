import Foundation
import Testing
import UIKit
import GovKit

@testable import govuk_ios

@Suite
@MainActor
struct ViewControllerBuilderBenefitsTests {

    @Test
    func makeBenefitsContainer_returnsExpectedResult() {
        let subject = ViewControllerBuilder()
        let result = subject.makeBenefitsContainer()

        let hostingController = result as? HostingViewController<BenefitsContainerView>
        #expect(hostingController?.rootView != nil)
        #expect(result.title == "Benefits")
        #expect(result.view.backgroundColor == .clear)
        #expect(result.navigationItem.largeTitleDisplayMode == .always)
    }
} 

