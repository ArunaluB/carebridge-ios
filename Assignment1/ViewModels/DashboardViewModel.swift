// Dashboard view model and supporting recommendation models.

import Foundation
import SwiftUI

// MARK: - Supporting Models

/// Action needed for today's records.
struct DashboardRecommendation: Identifiable {
    let id = UUID()
    let type: RecommendationType
    let child: ChildProfile
    let message: String
    let priority: RecommendationPriority
    let actionType: DiaryEntryType

    enum RecommendationPriority: Int, Comparable {
        case low    = 1
        case medium = 2
        case high   = 3

        static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

        var tintColor: Color {
            switch self {
            case .low:    return Color(hex: "74B9FF")   // Calm blue
            case .medium: return Color(hex: "FDCB6E")   // Amber
            case .high:   return Color(hex: "FF6B6B")   // Coral red
            }
        }

        var icon: String {
            switch self {
            case .low:    return "info.circle.fill"
            case .medium: return "exclamationmark.circle.fill"
            case .high:   return "exclamationmark.triangle.fill"
            }
        }

        var label: String {
            switch self {
            case .low:    return "Low"
            case .medium: return "Medium"
            case .high:   return "High"
            }
        }
    }

    enum RecommendationType {
        case missingWellbeing
        case missingMeal
        case nappyDue
        case missingSleep
        case allergyAlert
    }
}

/// Child with allergies who has a meal logged today.
struct AllergyAlertItem: Identifiable {
    let id = UUID()
    let child: ChildProfile
    let allergies: [Allergen]
    let mealTime: Date
}

// MARK: - DashboardViewModel

@Observable
class DashboardViewModel {

    // MARK: - Dependencies
    var dataManager: DataManager

    // MARK: - Search
    var searchText: String = ""

    // MARK: - Init
    init(dataManager: DataManager = .shared) {
        self.dataManager = dataManager
    }

    // MARK: - Profile

    var keyworker: KeyworkerProfile {
        dataManager.keyworker
    }

    // MARK: - Greeting

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12  { return "Good Morning" }
        if hour < 17  { return "Good Afternoon" }
        return "Good Evening"
    }

    var todayDateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, d MMMM yyyy"
        return f.string(from: Date())
    }

    // MARK: - Assigned Children (search-filtered)

    var assignedChildren: [ChildProfile] {
        dataManager.children.filter { child in
            guard !searchText.isEmpty else { return true }
            return child.fullName.localizedCaseInsensitiveContains(searchText) ||
                   child.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var childrenWithAllergies: [ChildProfile] {
        dataManager.childrenWithAllergies()
    }

    // MARK: - Quick Stats

    /// Number of distinct children who have at least 1 diary entry logged today.
    var childrenCheckedInToday: Int {
        let cal = Calendar.current
        let todayChildIDs = Set(
            dataManager.diaryEntries
                .filter { cal.isDateInToday($0.timestamp) }
                .map { $0.childId }
        )
        return todayChildIDs.count
    }

    /// Total number of diary entries logged for any child today.
    var entriesToday: Int {
        let cal = Calendar.current
        return dataManager.diaryEntries.filter { cal.isDateInToday($0.timestamp) }.count
    }

    /// Incidents reported this week.
    var weekIncidentCount: Int {
        dataManager.weekIncidentCount()
    }

    /// Total incidents pending manager review.
    var pendingIncidentCount: Int {
        dataManager.pendingReviewIncidents().count
    }

    /// Total actionable alerts.
    var activeAlerts: Int {
        allergyAlertItems.count +
        todayRecommendations.filter { $0.priority >= .medium }.count
    }

    // MARK: - Allergy Alert Items

    var allergyAlertItems: [AllergyAlertItem] {
        let cal = Calendar.current
        let todayMealEntriesByChild = Dictionary(grouping: dataManager.diaryEntries.filter {
            $0.type == .meal && cal.isDateInToday($0.timestamp)
        }, by: \.childId)

        return assignedChildren
            .filter { !$0.allergies.isEmpty }
            .compactMap { child -> AllergyAlertItem? in
                guard let meal = todayMealEntriesByChild[child.id]?.first else { return nil }
                return AllergyAlertItem(
                    child: child,
                    allergies: child.allergies,
                    mealTime: meal.timestamp
                )
            }
    }

    // MARK: - Today's Recommendations

    var todayRecommendations: [DashboardRecommendation] {
        var items: [DashboardRecommendation] = []
        let cal = Calendar.current
        let now = Date()
        let hour = cal.component(.hour, from: now)
        let todayEntriesByChild = Dictionary(grouping: dataManager.diaryEntries.filter {
            cal.isDateInToday($0.timestamp)
        }, by: \.childId)

        for child in assignedChildren {
            let todayEntries = todayEntriesByChild[child.id] ?? []

            // Arrival wellbeing check
            let hasArrivalWellbeing = todayEntries.contains {
                $0.type == .wellbeing &&
                ($0.wellbeingCheckTime == .arrival || $0.wellbeingCheckTime == WellbeingCheckTime.allCases.first)
            }
            if !hasArrivalWellbeing && hour >= 8 {
                items.append(DashboardRecommendation(
                    type: .missingWellbeing,
                    child: child,
                    message: "No arrival wellbeing check for \(child.firstName)",
                    priority: .high,
                    actionType: .wellbeing
                ))
            }

            // Midday wellbeing check
            if hour >= 11 {
                let hasMiddayWellbeing = todayEntries.contains {
                    $0.type == .wellbeing && $0.wellbeingCheckTime == .midday
                }
                if !hasMiddayWellbeing {
                    items.append(DashboardRecommendation(
                        type: .missingWellbeing,
                        child: child,
                        message: "Midday wellbeing check pending for \(child.firstName)",
                        priority: hour >= 13 ? .high : .medium,
                        actionType: .wellbeing
                    ))
                }
            }

            // Lunch not logged
            if hour >= 13 {
                let hasLunch = todayEntries.contains {
                    $0.type == .meal &&
                    cal.component(.hour, from: $0.timestamp) >= 11 &&
                    cal.component(.hour, from: $0.timestamp) <= 14
                }
                if !hasLunch {
                    items.append(DashboardRecommendation(
                        type: .missingMeal,
                        child: child,
                        message: "Lunch not yet recorded for \(child.firstName)",
                        priority: .medium,
                        actionType: .meal
                    ))
                }
            }

            // Nappy check overdue
            let ageInYears = child.dateOfBirth.ageInYears
            if ageInYears < 3 {
                let lastNappy = todayEntries
                    .filter { $0.type == .nappy }
                    .max { $0.timestamp < $1.timestamp }

                let hoursSinceNappy: Double
                if let nappy = lastNappy {
                    hoursSinceNappy = now.timeIntervalSince(nappy.timestamp) / 3600
                } else {
                    // No nappy change logged yet today.
                    hoursSinceNappy = Double(hour)
                }

                if hoursSinceNappy >= 3 {
                    let hrs = Int(hoursSinceNappy)
                    items.append(DashboardRecommendation(
                        type: .nappyDue,
                        child: child,
                        message: "Nappy check overdue for \(child.firstName) (\(hrs)h ago)",
                        priority: hoursSinceNappy >= 4 ? .high : .medium,
                        actionType: .nappy
                    ))
                }
            }

            // Rest period not logged
            if ageInYears < 3 && hour >= 14 {
                let hasSleep = todayEntries.contains { $0.type == .sleep }
                if !hasSleep {
                    items.append(DashboardRecommendation(
                        type: .missingSleep,
                        child: child,
                        message: "No rest period logged for \(child.firstName) today",
                        priority: .low,
                        actionType: .sleep
                    ))
                }
            }
        }

        // Highest priority first, then child name.
        return items.sorted {
            if $0.priority != $1.priority { return $0.priority > $1.priority }
            return $0.child.firstName < $1.child.firstName
        }
    }

    /// True when there are no recommendations or allergy alerts.
    var allRecordsUpToDate: Bool {
        todayRecommendations.isEmpty && allergyAlertItems.isEmpty
    }

    // MARK: - Per-Child Summary (for dashboard cards)

    func todayEntrySummary(for childId: UUID) -> (activities: Int, meals: Int, sleeps: Int, nappies: Int) {
        let entries = dataManager.todayEntriesForChild(childId)
        return (
            activities: entries.filter { $0.type == .activity }.count,
            meals:      entries.filter { $0.type == .meal }.count,
            sleeps:     entries.filter { $0.type == .sleep }.count,
            nappies:    entries.filter { $0.type == .nappy }.count
        )
    }

    func latestMood(for childId: UUID) -> MoodRating? {
        dataManager.todayEntriesForChild(childId)
            .filter { $0.type == .wellbeing && $0.moodRating != nil }
            .sorted { $0.timestamp > $1.timestamp }
            .first?.moodRating
    }

    func lastEntryTime(for childId: UUID) -> String {
        dataManager.todayEntriesForChild(childId).first?.timestamp.relativeTimeString ?? "No entries today"
    }

    // MARK: - Backward-Compat Properties

    var totalChildrenCount: Int { dataManager.children.count }

    var totalEntriesThisWeek: Int { dataManager.totalEntriesThisWeek() }

    // MARK: - Refresh
    /// Triggers observable recomputation for dashboard consumers.
    func refresh() {
        let _ = dataManager.diaryEntries.count
    }
}
