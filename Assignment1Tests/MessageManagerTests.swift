import XCTest
@testable import Assignment1

final class MessageManagerTests: XCTestCase {

    private var manager: MessageManager!

    override func setUp() {
        super.setUp()
        TestDataIsolation.clearAppPersistence()
        manager = MessageManager()
    }

    override func tearDown() {
        TestDataIsolation.clearAppPersistence()
        manager = nil
        super.tearDown()
    }

    func testUnreadCountMatchesInitialSampleState() {
        XCTAssertEqual(manager.unreadCount, 2)
    }

    func testMarkReadReducesUnreadCountByOne() {
        guard let firstUnread = manager.messages.first(where: { !$0.isRead }) else {
            return XCTFail("Expected at least one unread message in sample data")
        }

        let initial = manager.unreadCount
        manager.markRead(firstUnread.id)

        XCTAssertEqual(manager.unreadCount, initial - 1)
        XCTAssertTrue(manager.messages.first(where: { $0.id == firstUnread.id })?.isRead ?? false)
    }

    func testMarkAllReadSetsUnreadCountToZero() {
        manager.markAllRead()
        XCTAssertEqual(manager.unreadCount, 0)
        XCTAssertTrue(manager.messages.allSatisfy(\.isRead))
    }

    func testParentAndManagementMessageBucketsAreDisjointAndComplete() {
        let parentCount = manager.parentMessages.count
        let managementCount = manager.managementMessages.count

        XCTAssertEqual(parentCount + managementCount, manager.messages.count)
        XCTAssertTrue(manager.parentMessages.allSatisfy(\.isFromParent))
        XCTAssertTrue(manager.managementMessages.allSatisfy { !$0.isFromParent })
    }
}
