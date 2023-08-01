import XCTest
@testable import SimpleAnalytics

let successMsgTemplate = "Successfully submitted <%@> items"

final class SubmissionTests: XCTestCase {
    private let endpoint = "testEndpoint"
    private let appName = "AppAnalytics Tester"
    private let moveSquare = "move square"
    private let jumpFive = "jump 5"
    
    var manager = AppAnalytics(deviceID: UUID().uuidString, endpoint: "", appName: "")
    
    override func setUp() {
        manager = AppAnalytics(deviceID: UUID().uuidString, endpoint: endpoint, appName: appName)
    }
    
    func testSubmitSuccess() {
        manager.submitter = TestSubmitter(shouldSucceed: true)
        manager.addAnalyticsItem(moveSquare)
        manager.addAnalyticsItem(jumpFive)
        manager.addAnalyticsItem(moveSquare)
        manager.addAnalyticsItem(jumpFive)
        manager.addAnalyticsItem(moveSquare)
        manager.addAnalyticsItem(jumpFive)
        XCTAssertEqual(manager.items.count, 6)
        manager.clearAndSubmitItems()
        XCTAssertTrue(manager.items.isEmpty)
    }
    
    func testSubmitFailure() {
        manager.submitter = TestSubmitter(shouldSucceed: false)
        manager.setMaxCount(12)
        manager.maxCountResetValue = 5
        manager.addAnalyticsItem(moveSquare)
        manager.addAnalyticsItem(jumpFive)
        manager.addAnalyticsItem(moveSquare)
        manager.addAnalyticsItem(jumpFive)
        manager.addAnalyticsItem(moveSquare)
        manager.addAnalyticsItem(jumpFive)
        XCTAssertEqual(manager.items.count, 6)
        let strongManager = manager
        let strongMove = moveSquare
        let strongJump = jumpFive
        DispatchQueue.main.async {
            strongManager.clearAndSubmitItems()
            XCTAssertEqual(strongManager.items.count, 6)
            strongManager.addAnalyticsItem(strongMove)
            strongManager.addAnalyticsItem(strongJump)
            XCTAssertEqual(strongManager.items.count, 8)
            strongManager.addAnalyticsItem(strongMove)
            strongManager.addAnalyticsItem(strongJump)
            XCTAssertEqual(strongManager.items.count, 10)
            strongManager.addAnalyticsItem(strongMove)
            strongManager.addAnalyticsItem(strongJump)
            strongManager.addAnalyticsItem(strongMove)
            strongManager.addAnalyticsItem(strongJump)
            XCTAssertEqual(strongManager.items.count, 14)
            // maxCount should now be 17
            strongManager.submitter = TestSubmitter(shouldSucceed: true)
            strongManager.addAnalyticsItem(strongMove)
            strongManager.addAnalyticsItem(strongJump)
            // 17th item should result in successful submission and reset
            strongManager.addAnalyticsItem(strongMove)
            strongManager.addAnalyticsItem(strongJump)
            XCTAssertEqual(strongManager.items.count, 1)
        }
    }
    
    func testAutomaticSubmission() {
        manager.setMaxCount(5)
        manager.submitter = TestSubmitter(shouldSucceed: true)
        
        manager.addAnalyticsItem(moveSquare)
        XCTAssertEqual(manager.items.count, 1)
        manager.addAnalyticsItem(jumpFive)
        XCTAssertEqual(manager.items.count, 2)
        manager.addAnalyticsItem(moveSquare)
        XCTAssertEqual(manager.items.count, 3)
        manager.addAnalyticsItem(jumpFive)
        XCTAssertEqual(manager.items.count, 4)
        manager.addAnalyticsItem(moveSquare)
        XCTAssertEqual(manager.items.count, 0)
        manager.addAnalyticsItem(jumpFive)
        XCTAssertEqual(manager.items.count, 1)
    }
}


struct TestSubmitter: AnalyticsSubmitting {
    var shouldSucceed: Bool
    
    func submitItems(_ items: [AnalyticsItem], itemCounts: [AnalyticsCount],
                     successHandler: @escaping(String) -> Void,
                     errorHandler: @escaping([AnalyticsItem], [AnalyticsCount]) -> Void) {
        if shouldSucceed == true {
            successHandler(successMsgTemplate.replacingOccurrences(of: "<%@>", with: "\(items.count + itemCounts.count)"))
        } else {
            DispatchQueue.main.async {
                errorHandler(items, itemCounts)
            }
        }
    }
}
