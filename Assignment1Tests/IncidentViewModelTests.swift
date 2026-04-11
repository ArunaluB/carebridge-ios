import XCTest
@testable import Assignment1

final class IncidentViewModelTests: XCTestCase {

    private var dataManager: DataManager!
    private var viewModel: IncidentViewModel!

    override func setUp() {
        super.setUp()
        TestDataIsolation.clearAppPersistence()
        dataManager = DataManager()
        dataManager.incidents = []
        viewModel = IncidentViewModel(dataManager: dataManager)
    }

    override func tearDown() {
        TestDataIsolation.clearAppPersistence()
        viewModel = nil
        dataManager = nil
        super.tearDown()
    }

    func testSaveIncidentCreatesSubmittedIncidentAndTrimsInputs() {
        viewModel.selectedChildId = dataManager.children.first?.id
        viewModel.category = .minorAccident
        viewModel.location = "  Indoor corner  "
        viewModel.description = "  Child slipped while running near toys.  "
        viewModel.immediateActionTaken = "  First aid provided.  "
        viewModel.witnesses = ["  Staff A  ", "   "]

        viewModel.saveIncident()

        XCTAssertEqual(dataManager.incidents.count, 1)
        guard let incident = dataManager.incidents.first else {
            return XCTFail("Expected saved incident")
        }

        XCTAssertEqual(incident.status, .submitted)
        XCTAssertNotNil(incident.submittedAt)
        XCTAssertEqual(incident.location, "Indoor corner")
        XCTAssertEqual(incident.description, "Child slipped while running near toys.")
        XCTAssertEqual(incident.immediateActionTaken, "First aid provided.")
        XCTAssertEqual(incident.witnesses.count, 1)
        XCTAssertEqual(incident.witnesses.first, "  Staff A  ")
    }

    func testSimulateCountersignUpdatesWorkflowFields() {
        let incident = makeIncident(status: .submitted)
        dataManager.addIncident(incident)

        viewModel.simulateCountersign(incident)

        guard let updated = dataManager.incidents.first(where: { $0.id == incident.id }) else {
            return XCTFail("Expected countersigned incident")
        }

        XCTAssertEqual(updated.status, .countersigned)
        XCTAssertNotNil(updated.countersignedAt)
        XCTAssertNotNil(updated.reviewedAt)
        XCTAssertEqual(updated.reviewerName, "Claire Johnson (Setting Manager)")
    }

    func testSimulateParentNotificationUpdatesStatusAndTimestamp() {
        let incident = makeIncident(status: .countersigned)
        dataManager.addIncident(incident)

        viewModel.simulateParentNotification(incident)

        guard let updated = dataManager.incidents.first(where: { $0.id == incident.id }) else {
            return XCTFail("Expected parent-notified incident")
        }

        XCTAssertEqual(updated.status, .parentNotified)
        XCTAssertNotNil(updated.parentNotifiedAt)
    }

    func testBodyMapMarkerAddAndRemoveUpdatesCollection() {
        XCTAssertTrue(viewModel.bodyMapMarkers.isEmpty)

        viewModel.addBodyMapMarker(side: .front, x: 0.25, y: 0.4, label: "Bruise")
        XCTAssertEqual(viewModel.bodyMapMarkers.count, 1)

        let marker = viewModel.bodyMapMarkers[0]
        XCTAssertEqual(marker.side, .front)
        XCTAssertEqual(marker.label, "Bruise")

        viewModel.removeBodyMapMarker(marker)
        XCTAssertTrue(viewModel.bodyMapMarkers.isEmpty)
    }

    func testRemoveBodyMapMarkerFromEmptyCollectionRemainsSafe() {
        let marker = BodyMapMarker(side: .back, xPercent: 0.5, yPercent: 0.5, label: "Test")

        viewModel.removeBodyMapMarker(marker)

        XCTAssertTrue(viewModel.bodyMapMarkers.isEmpty)
    }

    private func makeIncident(status: IncidentStatus) -> Incident {
        Incident(
            childId: dataManager.children[0].id,
            keyworkerId: dataManager.keyworker.id,
            category: .firstAidRequired,
            status: status,
            location: "Play area",
            description: "Minor bump",
            immediateActionTaken: "Applied cold compress",
            witnesses: ["Staff Member"]
        )
    }
}
