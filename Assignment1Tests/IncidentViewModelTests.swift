import XCTest
@testable import Assignment1

final class IncidentViewModelTests: XCTestCase {
    private var dataManager: DataManager!
    private var viewModel: IncidentViewModel!

    override func setUp() {
        super.setUp()
        dataManager = DataManager()
        dataManager.resetToSampleData()
        viewModel = IncidentViewModel(dataManager: dataManager)
    }

    override func tearDown() {
        viewModel = nil
        dataManager = nil
        super.tearDown()
    }

    func testFormErrorsRequireMandatoryFields() {
        let errors = viewModel.formErrors

        XCTAssertTrue(errors.contains("Please select a child"))
        XCTAssertTrue(errors.contains("Please select an incident category"))
        XCTAssertTrue(errors.contains("Description is required"))
        XCTAssertTrue(errors.contains("Location is required"))
        XCTAssertTrue(errors.contains("Immediate action taken must be recorded"))
    }

    func testSaveIncidentPersistsSubmittedStatus() {
        let initialCount = dataManager.incidents.count

        viewModel.selectedChildId = dataManager.children.first?.id
        viewModel.category = .minorAccident
        viewModel.location = "Garden area"
        viewModel.description = "Child slipped while running and bumped knee on soft surface."
        viewModel.immediateActionTaken = "Cleaned area, applied cold compress, observed for discomfort."
        viewModel.witnesses = ["Staff A"]

        viewModel.saveIncident()

        XCTAssertEqual(dataManager.incidents.count, initialCount + 1)
        XCTAssertEqual(dataManager.incidents.first?.status, .submitted)
        XCTAssertEqual(viewModel.toast?.type, .success)
    }
}
