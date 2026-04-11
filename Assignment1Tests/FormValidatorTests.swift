import XCTest
@testable import Assignment1

final class FormValidatorTests: XCTestCase {

    func testIsNotEmptyTrimsWhitespace() {
        XCTAssertFalse(FormValidator.isNotEmpty("   \n  "))
        XCTAssertTrue(FormValidator.isNotEmpty("  valid text  "))
    }

    func testMinLengthUsesTrimmedText() {
        XCTAssertTrue(FormValidator.minLength("   1234567890   ", length: 10))
        XCTAssertFalse(FormValidator.minLength("   123456789   ", length: 10))
    }

    func testValidateIncidentFormMissingFieldsReturnsAllExpectedErrors() {
        let errors = FormValidator.validateIncidentForm(
            description: "",
            location: "",
            actionTaken: "",
            category: nil
        )

        XCTAssertEqual(errors.count, 5)
        XCTAssertTrue(errors.contains("Please select an incident category"))
        XCTAssertTrue(errors.contains("Description is required"))
        XCTAssertTrue(errors.contains("Description must be at least 10 characters"))
        XCTAssertTrue(errors.contains("Location is required"))
        XCTAssertTrue(errors.contains("Immediate action taken must be recorded"))
    }

    func testValidateIncidentFormValidInputReturnsNoErrors() {
        let errors = FormValidator.validateIncidentForm(
            description: "Child slipped while running indoors.",
            location: "Indoor play area",
            actionTaken: "Applied first aid and informed parent.",
            category: .minorAccident
        )

        XCTAssertTrue(errors.isEmpty)
    }

    func testValidateActivityLogRequiresTypeAndDescription() {
        let missingAll = FormValidator.validateActivityLog(activityType: nil, description: " ")
        XCTAssertEqual(missingAll.count, 2)

        let valid = FormValidator.validateActivityLog(activityType: .reading, description: "Read a story")
        XCTAssertTrue(valid.isEmpty)
    }
}
