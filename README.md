# NurseryConnect MVP (iOS)

NurseryConnect is an iOS MVP built for SE4020 (Mobile Application Design and Development, Semester 1 - 2026).

This build is intentionally scoped to match the assignment brief with a single role, exactly two core features, local persistence, and test coverage evidence.

## Assignment Alignment

- Module: SE4020
- Deliverable: iOS app (no backend/cloud implementation)
- Chosen role: Keyworker
- Implemented key features (exactly two):
	1. Daily Diary and Activity Monitoring
	2. Incident Reporting and Follow-up Workflow
- Navigation requirement: met (multi-screen SwiftUI navigation and sheet flows)
- Persistence requirement: met (SwiftData local storage with fallback handling)
- Testing requirement: met (unit + UI test suites wired to project)

## What This App Demonstrates

### 1) Daily Diary and Activity Monitoring

- Child-focused daily timeline logging
- Activity, meal, sleep, nappy, wellbeing, and note entries
- Validation and user feedback for required fields
- Day-based summary and tracking views

### 2) Incident Reporting and Follow-up

- Structured incident capture (category, location, narrative, action, witnesses)
- Status-oriented workflow for submission and review tracking
- Compliance-aware prompts in UX for safeguarding context
- Incident list and detail views for operational follow-up

## Tech Stack

- Language: Swift
- UI: SwiftUI
- Architecture style: MVVM-inspired separation (`Views`, `ViewModels`, `Services`, `Models`)
- Persistence: SwiftData (on-device), with in-memory fallback if storage init fails
- Testing: XCTest + XCUITest
- Dependencies: Native Apple frameworks only (no third-party libraries)

## Project Structure

```text
Assignment1/
	Assignment1/
		Components/
		Models/
		Services/
		Utilities/
		ViewModels/
		Views/
	Assignment1Tests/
	Assignment1UITests/
	Assignment1.xcodeproj/
	README.md
	SUBMISSION_NOTES.md
	DEMO_SCRIPT.md
	TESTING_GUIDE.md
```

## Run the App

### Xcode

1. Open `Assignment1.xcodeproj`.
2. Select scheme `Assignment1`.
3. Choose an iOS Simulator.
4. Run (`Cmd + R`).

### Command Line Build

```bash
xcodebuild -project Assignment1.xcodeproj -scheme Assignment1 -destination 'generic/platform=iOS Simulator' build
```

## Testing

The project includes wired test targets and starter suites:

- Unit tests: `Assignment1Tests/DiaryViewModelTests.swift`
- Unit tests: `Assignment1Tests/IncidentViewModelTests.swift`
- UI tests: `Assignment1UITests/Assignment1UITests.swift`

### Run all tests

```bash
xcodebuild -project Assignment1.xcodeproj -scheme Assignment1 -destination 'platform=iOS Simulator,name=iPhone 17' test
```

If your machine does not have `iPhone 17`, use any available simulator ID from:

```bash
xcodebuild -project Assignment1.xcodeproj -scheme Assignment1 -showdestinations
```

For detailed test setup/use, see `TESTING_GUIDE.md`.

## Compliance Positioning (MVP)

This app is designed to align with compliance expectations in the case study context:

- UK GDPR: data minimization-oriented local data handling
- EYFS 2024: daily records and safeguarding-aware prompts
- Ofsted / Children Act context: incident workflow cues for responsible documentation
- RIDDOR-oriented structure for incident categorization and traceability
- FSA-related context support via child dietary/allergy fields

Important: This MVP does not claim full legal/production compliance. A production system still requires backend controls such as robust access management, immutable audit logs, retention automation, secure backups, and operational governance.

## Submission and Viva Support

- Report support: `SUBMISSION_NOTES.md`
- Demo flow script: `DEMO_SCRIPT.md`
- Testing evidence guide: `TESTING_GUIDE.md`

## Screenshots (Evidence Template)

Use this section in your final submission package with real screenshots from your app/demo run.

1. App launch and main tab scope (Diary, Incidents, Settings)
2. Daily Diary entry creation flow
3. Daily Diary timeline/summary view
4. Incident form validation warning state
5. Incident saved and visible in incident list/detail
6. Settings screen showing storage mode/compliance wording
7. Xcode test navigator showing passing unit tests
8. Xcode test navigator showing passing UI tests

Recommended naming format:

- `01-main-scope.png`
- `02-diary-entry-form.png`
- `03-diary-summary.png`
- `04-incident-validation.png`
- `05-incident-list-detail.png`
- `06-settings-storage-compliance.png`
- `07-unit-tests-pass.png`
- `08-ui-tests-pass.png`

## 90+ Marks Quick Checklist

Use this list before final submission.

### Scope and Role

- [ ] Report starts with selected role: Keyworker
- [ ] Exactly two features are clearly named and justified
- [ ] No auth/login feature is presented as a core feature

### App Functionality

- [ ] App flow works without crashes on normal usage
- [ ] Navigation between required screens is smooth and clear
- [ ] Persistence works across app restarts (or fallback is explained)
- [ ] Validation/error states are visible and user-friendly

### UI and UX Quality

- [ ] Visual style is consistent across key screens
- [ ] Buttons, forms, and labels are easy to understand
- [ ] Sensitive workflow screens (incident/reporting) feel professional

### Swift/SwiftUI Quality

- [ ] Code is organized by feature/layer (`Views`, `ViewModels`, `Services`)
- [ ] SwiftUI components and state are used correctly
- [ ] At least one advanced concept is demonstrated (animations/charts/concurrency)

### Testing and Debugging

- [ ] Unit tests pass (`Assignment1Tests`)
- [ ] UI tests pass (`Assignment1UITests`)
- [ ] Test run screenshots are included in submission evidence

### Documentation and Compliance

- [ ] Report explains design and implementation decisions with reasons
- [ ] Challenges and trade-offs are described honestly
- [ ] Compliance section states MVP alignment without overclaiming
- [ ] Report distinguishes MVP behavior vs production-grade compliance requirements

## Known Scope Decisions

- App launches directly into core functionality after splash.
- Runtime navigation is focused on the two selected assignment features.
- `Settings` is retained for app metadata, storage mode visibility, and reset utilities.

## Author Note

This codebase is prepared for individual assignment submission, class demonstration, and viva discussion. Design and implementation decisions are documented to support technical justification under the marking rubric.
