    import XCTest
    @testable import SimpleAnalytics

    final class SimpleAnalyticsTests: XCTestCase {
        private let endpoint = "testEndpoint"
        private let appName = "AppAnalytics Tester"
        private let moveSquare = "move square"
        private let jumpFive = "jump 5"

        var manager = AppAnalytics(endpoint: "", appName: "")
        
        override func setUp() {
            manager = AppAnalytics(endpoint: endpoint, appName: appName)
        }
        
        func testNameAndEndpoint() {
            XCTAssertEqual(manager.endpoint, endpoint)
            XCTAssertEqual(manager.appName, appName)
        }
        
        func testAddItem() {
            let openFile = "open file"
            let loadView = "load  view"
            let exitGame = "exit game"
            
            manager.addAnalyticsItem(openFile)
            manager.addAnalyticsItem(loadView)
            manager.addAnalyticsItem(moveSquare)
            manager.addAnalyticsItem(jumpFive)
            manager.addAnalyticsItem(exitGame)
            
            let actions = manager.items
            XCTAssertEqual(actions.count, 5)
            XCTAssertEqual(actions[0].description, openFile)
            XCTAssertEqual(actions[1].description, loadView)
            XCTAssertEqual(actions[2].description, moveSquare)
            XCTAssertEqual(actions[3].description, jumpFive)
            XCTAssertEqual(actions[4].description, exitGame)
        }


        func testCount() {
            let moveCount = 5
            let jumpCount = 23
            
            for _ in 1...jumpCount {
                manager.countAnalyticsItem(jumpFive)
            }
            for _ in 1...moveCount {
                manager.countAnalyticsItem(moveSquare)
            }
            
            let counters = manager.itemCounts
            XCTAssertEqual(counters[jumpFive], jumpCount)
            XCTAssertEqual(counters[moveSquare], moveCount)
        }
        
    }
