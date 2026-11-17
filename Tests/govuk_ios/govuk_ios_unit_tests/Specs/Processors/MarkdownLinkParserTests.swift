import Testing
@testable import govuk_ios

@Suite
struct MarkdownLinkParserTests {
    let parser = MarkdownLinkParser()

    @Test
    func parse_plainText_returnsTextComponent() {
        let result = parser.parse("This is plain text")
        #expect(result.count == 1)
        if case .text(let text) = result[0] {
            #expect(text == "This is plain text")
        } else {
            Issue.record("Expected .text component")
        }
    }

    @Test
    func parse_emptyString_returnsTextComponent() {
        let result = parser.parse("")
        #expect(result.count == 1)
        if case .text(let text) = result[0] {
            #expect(text == "")
        } else {
            Issue.record("Expected .text component")
        }
    }

    @Test
    func parse_inlineLink_returnsLinkComponent() {
        let result = parser.parse("Check [GOV.UK](https://www.gov.uk)")
        #expect(result.count == 2)
        if case .text(let text) = result[0] {
            #expect(text == "Check ")
        } else {
            Issue.record("Expected .text component at index 0")
        }
        if case .link(let text, let url) = result[1] {
            #expect(text == "GOV.UK")
            #expect(url == "https://www.gov.uk")
        } else {
            Issue.record("Expected .link component at index 1")
        }
    }

    @Test
    func parse_noLinks_returnsTextComponent() {
        let result = parser.parse("No links here at all")
        #expect(result.count == 1)
        if case .text(let text) = result[0] {
            #expect(text == "No links here at all")
        } else {
            Issue.record("Expected .text component")
        }
    }

    @Test
    func parse_singleBullet_returnsBulletLinkComponent() {
        let markdown = "* [Contact us](https://www.gov.uk/contact)"
        let result = parser.parse(markdown)
        #expect(result.count == 1)
        if case .bulletLink(let text, let url, _, _) = result[0] {
            #expect(text == "Contact us")
            #expect(url == "https://www.gov.uk/contact")
        } else {
            Issue.record("Expected .bulletLink component")
        }
    }

    @Test
    func parse_multipleBullets_returnsBulletLinkComponents() {
        let markdown = """
        * [First link](https://example.com)
        * [Second link](https://example.com)
        """
        let result = parser.parse(markdown)
        #expect(result.count == 2)
        if case .bulletLink = result[0], case .bulletLink = result[1] {
            // Both are bullet links
        } else {
            Issue.record("Expected two .bulletLink components")
        }
    }

    @Test
    func parse_firstBullet_topSpacingIsZero() {
        let markdown = "* [First](https://example.com)"
        let result = parser.parse(markdown)
        if case .bulletLink(_, _, let topSpacing, _) = result[0] {
            #expect(topSpacing == 0)
        } else {
            Issue.record("Expected .bulletLink component")
        }
    }

    @Test
    func parse_consecutiveBullets_topSpacingIsFive() {
        let markdown = """
        * [First](https://example.com)
        * [Second](https://example.com)
        """
        let result = parser.parse(markdown)
        if case .bulletLink(_, _, let topSpacing, _) = result[1] {
            #expect(topSpacing == 5)
        } else {
            Issue.record("Expected .bulletLink component at index 1")
        }
    }

    @Test
    func parse_bulletAfterText_topSpacingIsSixteen() {
        let markdown = """
        Some introductory text
        * [Link](https://example.com)
        """
        let result = parser.parse(markdown)
        if case .bulletLink(_, _, let topSpacing, _) = result[1] {
            #expect(topSpacing == 16)
        } else {
            Issue.record("Expected .bulletLink component at index 1")
        }
    }

    @Test
    func parse_lastBullet_bottomSpacingIsZero() {
        let markdown = "* [Link](https://example.com)"
        let result = parser.parse(markdown)
        if case .bulletLink(_, _, _, let bottomSpacing) = result[0] {
            #expect(bottomSpacing == 0)
        } else {
            Issue.record("Expected .bulletLink component")
        }
    }

    @Test
    func parse_bulletFollowedByBullet_bottomSpacingIsZero() {
        let markdown = """
        * [First](https://example.com)
        * [Second](https://example.com)
        """
        let result = parser.parse(markdown)
        if case .bulletLink(_, _, _, let bottomSpacing) = result[0] {
            #expect(bottomSpacing == 0)
        } else {
            Issue.record("Expected .bulletLink component at index 0")
        }
    }

    @Test
    func parse_bulletFollowedByText_bottomSpacingIsSixteen() {
        let markdown = """
        * [Link](https://example.com)
        Some trailing text
        """
        let result = parser.parse(markdown)
        if case .bulletLink(_, _, _, let bottomSpacing) = result[0] {
            #expect(bottomSpacing == 16)
        } else {
            Issue.record("Expected .bulletLink component at index 0")
        }
    }

    @Test
    func parse_textThenBulletList_returnsCorrectComponentSequence() {
        let markdown = """
        More information:
        * [GOV.UK homepage](https://www.gov.uk)
        * [Contact us](https://www.gov.uk/contact)
        """
        let result = parser.parse(markdown)
        #expect(result.count == 3)
        if case .text = result[0], case .bulletLink = result[1], case .bulletLink = result[2] {
            // Correct sequence
        } else {
            Issue.record("Expected .text, .bulletLink, .bulletLink sequence")
        }
    }

    @Test
    func parse_multipleBulletsWithTrailingText_correctSpacing() {
        let markdown = """
        Options:
        * [Option one](https://example.com)
        * [Option two](https://example.com)
        For more details visit our site.
        """
        let result = parser.parse(markdown)
        #expect(result.count == 4)

        if case .bulletLink(_, _, _, let spacing1) = result[1] {
            #expect(spacing1 == 0, "First bullet followed by second bullet should have 0 bottom spacing")
        }

        if case .bulletLink(_, _, _, let spacing2) = result[2] {
            #expect(spacing2 == 16, "Second bullet followed by text should have 16 bottom spacing")
        }
    }

    @Test
    func parse_bulletWithLeadingParagraph_correctTopSpacing() {
        let markdown = """
        Some paragraph text.

        * [Link](https://example.com)
        """
        let result = parser.parse(markdown)
        if case .bulletLink(_, _, let topSpacing, _) = result[1] {
            #expect(topSpacing == 16, "Bullet after text paragraph should have 16 top spacing")
        } else {
            Issue.record("Expected .bulletLink component at index 1")
        }
    }

    @Test
    func parse_multipleBulletsAndText_fullFlow() {
        let markdown = """
        Before bullets
        * [Link one](https://example.com)
        * [Link two](https://example.com)
        After bullets
        """
        let result = parser.parse(markdown)

        // Verify structure
        #expect(result.count == 4)

        // Verify first bullet has 16 top spacing (after text)
        if case .bulletLink(_, _, let topSpacing, _) = result[1] {
            #expect(topSpacing == 16)
        }

        // Verify second bullet has 5 top spacing (after bullet)
        if case .bulletLink(_, _, let topSpacing, _) = result[2] {
            #expect(topSpacing == 5)
        }

        // Verify second bullet has 16 bottom spacing (before text)
        if case .bulletLink(_, _, _, let bottomSpacing) = result[2] {
            #expect(bottomSpacing == 16)
        }
    }
}
