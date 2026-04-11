import XCTest
@testable import Assignment1

final class SleepTrackerManagerTests: XCTestCase {

    private var manager: SleepTrackerManager!

    override func setUp() {
        super.setUp()
        manager = SleepTrackerManager()
        manager.activeSleepSessions = [:]
        manager.sleepEntryIds = [:]
        TestDataIsolation.clearAppPersistence()
    }

    override func tearDown() {
        TestDataIsolation.clearAppPersistence()
        manager = nil
        super.tearDown()
    }

    func testSleepDurationFormatsMinutesAndHours() {
        let childId = UUID()
        let now = Date()

        manager.activeSleepSessions[childId] = now.addingTimeInterval(-42 * 60)
        XCTAssertEqual(manager.sleepDuration(for: childId, now: now), "42 min")

        manager.activeSleepSessions[childId] = now.addingTimeInterval(-65 * 60)
        XCTAssertEqual(manager.sleepDuration(for: childId, now: now), "1h 5min")
    }

    func testLiveTimerStringUsesHHMMSSFormat() {
        let childId = UUID()
        let now = Date()
        manager.activeSleepSessions[childId] = now.addingTimeInterval(-3661)

        XCTAssertEqual(manager.liveTimerString(for: childId, now: now), "01:01:01")
    }

    func testEndSleepWithoutActiveSessionReturnsEmptyString() {
        let result = manager.endSleep(for: UUID(), dataManager: DataManager())
        XCTAssertEqual(result, "")
    }

    func testStartAndEndSleepLifecycleUpdatesDiaryEntryAndState() {
        let childId = SampleData.children[0].id
        let dataManager = DataManager()
        dataManager.diaryEntries = []

        manager.startSleep(for: childId, dataManager: dataManager)

        XCTAssertTrue(manager.isAsleep(childId))
        XCTAssertEqual(dataManager.diaryEntries.count, 1)

        let result = manager.endSleep(for: childId, dataManager: dataManager)

        XCTAssertFalse(result.isEmpty)
        XCTAssertFalse(manager.isAsleep(childId))
        XCTAssertNil(manager.sleepEntryIds[childId])

        let entry = dataManager.diaryEntries[0]
        XCTAssertNotNil(entry.sleepEndTime)
        XCTAssertNotNil(entry.sleepDurationMinutes)
    }

}
