// Shared app-level state used by ContentView and the custom tab/FAB flow.

import SwiftUI

// MARK: - AppState
@Observable
final class AppState {

    // MARK: FAB Navigation State
    /// The entry type the user tapped from the FAB menu.
    /// nil means no selection has been made yet.
    var fabSelectedEntryType: DiaryEntryType? = nil

    /// Set when the FAB entry form should be presented by ContentView.
    var showFABSheet: Bool = false

    /// Shows a child picker before opening the FAB entry form.
    var showChildPickerFirst: Bool = false

    // MARK: - Sheet Navigation
    var showNotificationCenter: Bool = false
    var showMessagesView: Bool = false
    var showAttendanceView: Bool = false
    var showEndOfDayChecklist: Bool = false

    // MARK: - Global Toast
    /// Global toast container surfaced by ContentView.
    var globalToast: ToastData? = nil

    // MARK: - FAB Trigger
    /// Triggers the FAB entry flow.
    func triggerFAB(entryType: DiaryEntryType, hasSelectedChild: Bool) {
        fabSelectedEntryType = entryType
        if hasSelectedChild {
            showFABSheet = true
        } else {
            showChildPickerFirst = true
        }
    }

    /// Resets transient FAB navigation state.
    func resetFABState() {
        fabSelectedEntryType = nil
        showFABSheet = false
        showChildPickerFirst = false
    }
}
