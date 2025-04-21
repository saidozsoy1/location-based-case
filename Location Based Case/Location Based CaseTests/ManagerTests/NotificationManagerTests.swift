import XCTest
@testable import Location_Based_Case

class NotificationManagerTests: XCTestCase {
    
    class TestObserver: NSObject {
        var receivedNotification = false
        var receivedUserInfo: TestNotificationUserInfo?
        
        @objc func handleNotification(_ notification: Notification) {
            receivedNotification = true
            if let userInfo = notification.userInfo as? [String: String] {
                let testUserInfo = TestNotificationUserInfo(data: userInfo["data"])
                receivedUserInfo = testUserInfo
            }
        }
    }
    
    class TestNotificationUserInfo: NotificationUserInfo {
        let data: String?
        
        init(data: String?) {
            self.data = data
        }
        
        required init?(notification: NSNotification) {
            guard let userInfo = notification.userInfo as? [String: String] else {
                return nil
            }
            self.data = userInfo["data"]
        }
        
        func toDictionary() -> [AnyHashable : Any] {
            return ["data": data as Any]
        }
    }
    
    // Test notification name
    static let testNotificationName = Notification.Name("TestNotification")
    
    var testObserver: TestObserver!
    
    override func setUp() {
        super.setUp()
        testObserver = TestObserver()
    }
    
    override func tearDown() {
        NotificationCenter.default.removeObserver(testObserver)
        testObserver = nil
        super.tearDown()
    }
    
    func testPostAndListenNotification() {
        // Given
        NotificationManager.listen(testObserver, selector: #selector(TestObserver.handleNotification(_:)), name: NotificationManagerTests.testNotificationName)
        
        // When
        NotificationManager.post(NotificationManagerTests.testNotificationName)
        
        // Then
        XCTAssertTrue(testObserver.receivedNotification)
    }
    
    func testPostAndListenNotificationWithUserInfo() {
        // Given
        let testUserInfo = TestNotificationUserInfo(data: "Test Data")
        NotificationManager.listen(testObserver, selector: #selector(TestObserver.handleNotification(_:)), name: NotificationManagerTests.testNotificationName)
        
        // When
        NotificationManager.post(NotificationManagerTests.testNotificationName, userInfo: testUserInfo)
        
        // Then
        XCTAssertTrue(testObserver.receivedNotification)
        XCTAssertEqual(testObserver.receivedUserInfo?.data, "Test Data")
    }
    
    func testRemoveObserver() {
        // Given
        NotificationManager.listen(testObserver, selector: #selector(TestObserver.handleNotification(_:)), name: NotificationManagerTests.testNotificationName)
        
        // When
        NotificationManager.removeObserver(testObserver, name: NotificationManagerTests.testNotificationName)
        NotificationManager.post(NotificationManagerTests.testNotificationName)
        
        // Then
        XCTAssertFalse(testObserver.receivedNotification) // Notification should not be received after observer is removed
    }
    
    func testNotificationUserInfoInit() {
        // Given
        let testUserInfo = TestNotificationUserInfo(data: "Test Data")
        let userInfoDict = testUserInfo.toDictionary()
        
        // When
        let notification = NSNotification(name: NotificationManagerTests.testNotificationName, object: nil, userInfo: userInfoDict)
        let parsedUserInfo = TestNotificationUserInfo(notification: notification)
        
        // Then
        XCTAssertNotNil(parsedUserInfo)
        XCTAssertEqual(parsedUserInfo?.data, "Test Data")
    }
    
    func testNotificationUserInfoInitFailsWithInvalidData() {
        // Given
        let invalidUserInfo: [AnyHashable: Any] = ["invalidKey": 123] // Wrong format
        
        // When
        let notification = NSNotification(name: NotificationManagerTests.testNotificationName, object: nil, userInfo: invalidUserInfo)
        let parsedUserInfo = TestNotificationUserInfo(notification: notification)
        
        // Then
        XCTAssertNil(parsedUserInfo)
    }
    
    func testMultipleObservers() {
        // Given
        let secondObserver = TestObserver()
        NotificationManager.listen(testObserver, selector: #selector(TestObserver.handleNotification(_:)), name: NotificationManagerTests.testNotificationName)
        NotificationManager.listen(secondObserver, selector: #selector(TestObserver.handleNotification(_:)), name: NotificationManagerTests.testNotificationName)
        
        // When
        NotificationManager.post(NotificationManagerTests.testNotificationName)
        
        // Then
        XCTAssertTrue(testObserver.receivedNotification)
        XCTAssertTrue(secondObserver.receivedNotification)
        
        // Clean up
        NotificationCenter.default.removeObserver(secondObserver)
    }
}
