// End-of-day checklist computed from current app state.

import SwiftUI

// MARK: - Checklist Item

struct ChecklistItem: Identifiable {
    var id: String { title }
    let title: String
    let status: ChecklistStatus
    let detail: String
    let icon: String
}

enum ChecklistStatus {
    case complete
    case incomplete
    case warning

    var color: Color {
        switch self {
        case .complete: return Color(hex: "55EFC4")
        case .incomplete: return Color(hex: "FF6B6B")
        case .warning: return Color(hex: "F4A261")
        }
    }

    var icon: String {
        switch self {
        case .complete: return "checkmark.circle.fill"
        case .incomplete: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - EndOfDayChecklistView

struct EndOfDayChecklistView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(AttendanceManager.self) private var attendanceManager
    @Environment(\.dismiss) private var dismiss

    private var checklistItems: [ChecklistItem] {
        let children = dataManager.children
        let cal = Calendar.current
        let todayEntries = dataManager.diaryEntries.filter { cal.isDateInToday($0.timestamp) }

        var items: [ChecklistItem] = []

        // 1. Attendance complete
        let allAccountedFor = attendanceManager.allCheckedOut(childIds: children.map { $0.id })
        let presentOrAbsent = children.filter {
            let s = attendanceManager.state(for: $0.id)
            return s == .checkedOut || s == .absent || s == .checkedIn
        }
        items.append(ChecklistItem(
            title: "Attendance Register Complete",
            status: presentOrAbsent.count == children.count ? .complete : .incomplete,
            detail: "\(presentOrAbsent.count)/\(children.count) children accounted for",
            icon: "person.badge.clock"
        ))

        // 2. All children collected
        items.append(ChecklistItem(
            title: "All Children Collected",
            status: allAccountedFor ? .complete : .warning,
            detail: allAccountedFor ? "All children checked out or marked absent" : "\(attendanceManager.presentCount) still on premises",
            icon: "arrow.right.circle"
        ))

        // 3. Wellbeing checks
        let wellbeingEntries = todayEntries.filter { $0.type == .wellbeing }
        let childrenWithWellbeing = Set(wellbeingEntries.map { $0.childId })
        let activeChildren = children.filter { attendanceManager.state(for: $0.id) != .absent }
        let wellbeingComplete = activeChildren.allSatisfy { childrenWithWellbeing.contains($0.id) }
        items.append(ChecklistItem(
            title: "Wellbeing Checks Recorded",
            status: wellbeingComplete ? .complete : (childrenWithWellbeing.count > 0 ? .warning : .incomplete),
            detail: "\(childrenWithWellbeing.count)/\(activeChildren.count) children checked",
            icon: "heart.fill"
        ))

        // 4. Meals logged
        let mealEntries = todayEntries.filter { $0.type == .meal }
        let childrenWithMeals = Set(mealEntries.map { $0.childId })
        let mealsComplete = activeChildren.allSatisfy { childrenWithMeals.contains($0.id) }
        items.append(ChecklistItem(
            title: "Meals Logged",
            status: mealsComplete ? .complete : (childrenWithMeals.count > 0 ? .warning : .incomplete),
            detail: "\(childrenWithMeals.count)/\(activeChildren.count) children — \(mealEntries.count) entries",
            icon: "fork.knife"
        ))

        // 5. Nappy checks (under-3s)
        let under3s = activeChildren.filter { $0.dateOfBirth.ageInYears < 3 }
        if !under3s.isEmpty {
            let nappyEntries = todayEntries.filter { $0.type == .nappy }
            let childrenWithNappies = Set(nappyEntries.map { $0.childId })
            let nappiesComplete = under3s.allSatisfy { childrenWithNappies.contains($0.id) }
            items.append(ChecklistItem(
                title: "Nappy Checks (Under 3s)",
                status: nappiesComplete ? .complete : .warning,
                detail: "\(childrenWithNappies.intersection(Set(under3s.map { $0.id })).count)/\(under3s.count) children checked",
                icon: "arrow.triangle.2.circlepath"
            ))
        }

        // 6. Sleep logged (under-3s)
        if !under3s.isEmpty {
            let sleepEntries = todayEntries.filter { $0.type == .sleep }
            let childrenWithSleep = Set(sleepEntries.map { $0.childId })
            let sleepComplete = under3s.allSatisfy { childrenWithSleep.contains($0.id) }
            items.append(ChecklistItem(
                title: "Rest Periods (Under 3s)",
                status: sleepComplete ? .complete : .warning,
                detail: "\(childrenWithSleep.intersection(Set(under3s.map { $0.id })).count)/\(under3s.count) — rest recorded",
                icon: "moon.zzz.fill"
            ))
        }

        // 7. Incidents countersigned
        let todayIncidents = dataManager.incidents.filter { cal.isDateInToday($0.dateTime) }
        if !todayIncidents.isEmpty {
            let allCountersigned = todayIncidents.allSatisfy {
                $0.status == .countersigned || $0.status == .parentNotified || $0.status == .acknowledged
            }
            items.append(ChecklistItem(
                title: "Incidents Countersigned",
                status: allCountersigned ? .complete : .incomplete,
                detail: "\(todayIncidents.count) incident(s) today",
                icon: "signature"
            ))
        }

        // 8. Activities logged
        let activityEntries = todayEntries.filter { $0.type == .activity }
        items.append(ChecklistItem(
            title: "Activities Documented",
            status: activityEntries.count >= activeChildren.count ? .complete : .warning,
            detail: "\(activityEntries.count) activities logged today",
            icon: "figure.play"
        ))

        return items
    }

    private func completionPercentage(for items: [ChecklistItem]) -> Double {
        let complete = items.filter { $0.status == .complete }.count
        return items.isEmpty ? 0 : Double(complete) / Double(items.count)
    }

    var body: some View {
        let items = checklistItems

        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // MARK: Header
                    headerSection

                    // MARK: Progress Ring
                    progressSection(items: items)

                    // MARK: Checklist Items
                    VStack(spacing: 10) {
                        ForEach(items) { item in
                            checklistRow(item)
                        }
                    }

                    // MARK: Generate Reports
                    generateReportsButton

                    // MARK: Compliance Footer
                    complianceFooter

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .background(Color.ncBackground)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ncPrimary)
                }
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("End-of-Day Checklist")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ncText)
            
            Text("Automated EYFS compliance audit. Ensure all critical daily tasks are completed.")
                .font(.system(size: 13))
                .foregroundStyle(Color.ncTextSec)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }

    // MARK: - Progress Section
    private func progressSection(items: [ChecklistItem]) -> some View {
        let percentage = completionPercentage(for: items)

        return VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 8)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: percentage)
                    .stroke(
                        percentage >= 1.0
                            ? Color(hex: "55EFC4")
                            : Color.ncPrimary,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(Int(percentage * 100))%")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.ncText)
                    Text("Complete")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.ncTextSec)
                }
            }

            let complete = items.filter { $0.status == .complete }.count
            Text("\(complete) of \(items.count) items complete")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.ncTextSec)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        )
        .accessibilityLabel("End of day checklist progress: \(Int(percentage * 100)) percent complete")
    }

    // MARK: - Checklist Row
    private func checklistRow(_ item: ChecklistItem) -> some View {
        HStack(spacing: 14) {
            // Status icon
            Image(systemName: item.status.icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(item.status.color)
                .frame(width: 28)

            // Content
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.ncText)

                Text(item.detail)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.ncTextSec)
            }

            Spacer()

            // Category icon
            Image(systemName: item.icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.ncTextSec.opacity(0.5))
        }
        .padding(14)
        .frame(minHeight: 44)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(item.status.color.opacity(0.12), lineWidth: 1)
        )
        .accessibilityLabel("\(item.title): \(item.status == .complete ? "complete" : item.status == .incomplete ? "incomplete" : "warning"). \(item.detail)")
    }

    // MARK: - Generate Reports Button
    private var generateReportsButton: some View {
        Button {
            HapticManager.success()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 15, weight: .bold))
                Text("Generate Daily Reports")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color.ncPrimary, Color(hex: "44B09E")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.ncPrimary.opacity(0.3), radius: 8, y: 4)
            )
        }
        .accessibilityLabel("Generate daily reports for all children")
    }

    // MARK: - Compliance Footer
    private var complianceFooter: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 11))
                .foregroundStyle(Color.ncPrimary)
            Text("This checklist is generated automatically per EYFS 2024 Section 3.64 and Ofsted Early Years Compliance Handbook requirements.")
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(Color.ncTextSec)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.ncPrimary.opacity(0.04))
        )
    }
}

// MARK: - Preview
#Preview {
    EndOfDayChecklistView()
        .environment(DataManager.shared)
        .environment(AttendanceManager.shared)
}
