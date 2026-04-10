import XCTest
@testable import Assignment1

final class DiaryViewModelTests: XCTestCase {
    private var dataManager: DataManager!
    private var viewModel: DiaryViewModel!

    override func setUp() {
        super.setUp()
        dataManager = DataManager()
        dataManager.resetToSampleData()
        viewModel = DiaryViewModel(dataManager: dataManager)
        viewModel.selectedChildId = dataManager.children.first?.id
    }

    override func tearDown() {
        viewModel = nil
        dataManager = nil
        super.tearDown()
    }

    func testSaveActivityEntryAddsNewEntry() {
        let initialCount = dataManager.diaryEntries.count

        viewModel.selectedEntryType = .activity
        viewModel.activityType = .outdoorPlay
        viewModel.activityNotes = "Outdoor balancing and ball play"
        viewModel.eyfsArea = "Physical Development"

        viewModel.saveEntry()

        XCTAssertEqual(dataManager.diaryEntries.count, initialCount + 1)
        XCTAssertEqual(viewModel.toast?.type, .success)
    }

    func testSleepEntryRejectsInvalidDuration() {
        viewModel.selectedEntryType = .sleep
        viewModel.sleepStartTime = Date()
        viewModel.sleepEndTime = Date().addingTimeInterval(-300)

        viewModel.saveEntry()

        XCTAssertEqual(viewModel.toast?.type, .warning)
        XCTAssertEqual(viewModel.toast?.message, "Sleep end time must be after start time")
    }
}
