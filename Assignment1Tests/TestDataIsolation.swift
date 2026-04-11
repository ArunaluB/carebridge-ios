import Foundation

// Centralized test cleanup to avoid cross-test pollution from UserDefaults-backed services.
enum TestDataIsolation {
    static func clearAppPersistence() {
        UserDefaults.standard.removeObject(forKey: "nc_keyworker")
        UserDefaults.standard.removeObject(forKey: "nc_children")
        UserDefaults.standard.removeObject(forKey: "nc_diary_entries")
        UserDefaults.standard.removeObject(forKey: "nc_incidents")
        UserDefaults.standard.removeObject(forKey: "nc_attendance_records")
        UserDefaults.standard.removeObject(forKey: "nc_has_launched_before")
    }
}
