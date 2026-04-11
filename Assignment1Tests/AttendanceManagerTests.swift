import XCTest
@testable import Assignment1

final class AttendanceManagerTests: XCTestCase {

    private var manager: AttendanceManager!
    private let testChild = SampleData.children[0]

    override func setUp() {
        super.setUp()
        TestDataIsolation.clearAppPersistence()
        manager = AttendanceManager()
        manager.records = []
    }

    override func tearDown() {
        TestDataIsolation.clearAppPersistence()
        manager = nil
        super.tearDown()
    }

    func testCheckInCreatesRecordAndStateIsCheckedIn() {
        manager.checkIn(child: testChild, droppedOffBy: "Parent")

        XCTAssertEqual(manager.records.count, 1)
        XCTAssertEqual(manager.state(for: testChild.id), .checkedIn)
        XCTAssertNotNil(manager.todayRecord(for: testChild.id)?.checkInTime)
    }

    func testCheckInIsIdempotentForSameDay() {
        manager.checkIn(child: testChild, droppedOffBy: "Parent A")
        manager.checkIn(child: testChild, droppedOffBy: "Parent B")

        XCTAssertEqual(manager.records.count, 1)
        XCTAssertEqual(manager.todayRecord(for: testChild.id)?.droppedOffBy, "Parent B")
    }

    func testCheckOutMovesStateToCheckedOut() {
        manager.checkIn(child: testChild, droppedOffBy: "Parent")
        manager.checkOut(child: testChild, collectedBy: "Guardian", authorised: true)

        XCTAssertEqual(manager.state(for: testChild.id), .checkedOut)
        XCTAssertNotNil(manager.todayRecord(for: testChild.id)?.checkOutTime)
    }

    func testMarkAbsentOverridesCheckedInState() {
        manager.checkIn(child: testChild, droppedOffBy: "Parent")
        manager.markAbsent(child: testChild, reason: "Unwell")

        let record = manager.todayRecord(for: testChild.id)
        XCTAssertEqual(manager.state(for: testChild.id), .absent)
        XCTAssertTrue(record?.isAbsent ?? false)
        XCTAssertNil(record?.checkInTime)
        XCTAssertNil(record?.checkOutTime)
    }

    func testAllCheckedOutTreatsAbsentAsCompletedDay() {
        let childA = SampleData.children[0]
        let childB = SampleData.children[1]

        manager.checkIn(child: childA, droppedOffBy: "Parent")
        manager.checkOut(child: childA, collectedBy: "Guardian", authorised: true)
        manager.markAbsent(child: childB, reason: "Holiday")

        XCTAssertTrue(manager.allCheckedOut(childIds: [childA.id, childB.id]))
    }

    func testAttendancePersistsAcrossManagerReinitialization() {
        let child = SampleData.children[0]

        manager.checkIn(child: child, droppedOffBy: "Parent Persist")

        let reloadedManager = AttendanceManager()
        let record = reloadedManager.todayRecord(for: child.id)

        XCTAssertNotNil(record)
        XCTAssertEqual(record?.droppedOffBy, "Parent Persist")
        XCTAssertEqual(reloadedManager.state(for: child.id), .checkedIn)
    }

    func testTodayCountsReflectDifferentStates() {
        let now = Date()
        manager.records = [
            AttendanceRecord(childId: UUID(), date: now, checkInTime: now),
            AttendanceRecord(childId: UUID(), date: now),
            AttendanceRecord(childId: UUID(), date: now, isAbsent: true, absenceReason: "Sick"),
            AttendanceRecord(childId: UUID(), date: now, checkInTime: now, checkOutTime: now)
        ]

        XCTAssertEqual(manager.presentCount, 1)
        XCTAssertEqual(manager.expectedCount, 1)
        XCTAssertEqual(manager.absentCount, 1)
        XCTAssertEqual(manager.checkedOutCount, 1)
    }
}
