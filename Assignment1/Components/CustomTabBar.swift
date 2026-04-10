// Custom tab bar and FAB menu used by the main app container.

import SwiftUI

// MARK: - Tab Item Enum
enum TabItem: Int, CaseIterable, Identifiable {
    case diary     = 0
    case addNew    = 1
    case incidents = 2
    case settings  = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .diary:     return "Diary"
        case .addNew:    return ""
        case .incidents: return "Incidents"
        case .settings:  return "Settings"
        }
    }

    /// SF Symbol used when this tab is the active selection (filled variant).
    var activeIcon: String {
        switch self {
        case .diary:     return "book.fill"
        case .addNew:    return "plus"
        case .incidents: return "exclamationmark.shield.fill"
        case .settings:  return "gearshape.fill"
        }
    }

    /// SF Symbol used in the inactive state (outline/lighter variant).
    var inactiveIcon: String {
        switch self {
        case .diary:     return "book"
        case .addNew:    return "plus"
        case .incidents: return "exclamationmark.shield"
        case .settings:  return "gearshape"
        }
    }
}

// MARK: - FAB Action Model
struct FABActionItem: Identifiable {
    let id       = UUID()
    let type     : DiaryEntryType
    let label    : String
    let icon     : String
    let gradient : [Color]
}

/// Shared FAB actions used by tab bar previews and menu rows.
extension FABActionItem {
    static let all: [FABActionItem] = [
        FABActionItem(
            type:     .activity,
            label:    "Log Activity",
            icon:     "figure.play",
            gradient: [Color(hex: "4ECDC4"), Color(hex: "44B09E")]
        ),
        FABActionItem(
            type:     .meal,
            label:    "Record Meal",
            icon:     "fork.knife",
            gradient: [Color(hex: "FF9F43"), Color(hex: "EE5A24")]
        ),
        FABActionItem(
            type:     .sleep,
            label:    "Log Sleep",
            icon:     "moon.zzz.fill",
            gradient: [Color(hex: "A29BFE"), Color(hex: "6C5CE7")]
        ),
        FABActionItem(
            type:     .nappy,
            label:    "Nappy Change",
            icon:     "arrow.triangle.2.circlepath",
            gradient: [Color(hex: "FFEAA7"), Color(hex: "FDCB6E")]
        ),
        FABActionItem(
            type:     .wellbeing,
            label:    "Wellbeing Check",
            icon:     "heart.fill",
            gradient: [Color(hex: "FF6B6B"), Color(hex: "C0392B")]
        ),
        FABActionItem(
            type:     .note,
            label:    "Add Note",
            icon:     "note.text",
            gradient: [Color(hex: "B2BEC3"), Color(hex: "636E72")]
        ),
    ]
}

// MARK: - Scale Press Button Style
struct ScalePressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(
                .spring(response: 0.25, dampingFraction: 0.7),
                value: configuration.isPressed
            )
    }
}

// MARK: - CustomTabBar
struct CustomTabBar: View {

    @Binding var selectedTab: TabItem
    @Binding var showAddMenu: Bool

    @Environment(AppState.self)    private var appState
    @Environment(DataManager.self) private var dataManager
    @Environment(\.colorScheme)    private var colorScheme

    /// Idle pulse when the FAB menu is collapsed.
    @State private var fabPulse: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases) { tab in
                if tab == .addNew {
                    fabButton
                } else {
                    tabButton(tab)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(tabBarBackground)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 0.5)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                fabPulse = true
            }
        }
    }

    // MARK: - Regular Tab Button
    @ViewBuilder
    private func tabButton(_ tab: TabItem) -> some View {
        let isActive = selectedTab == tab

        Button {
            HapticManager.selection()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isActive ? tab.activeIcon : tab.inactiveIcon)
                    .font(.system(size: 20, weight: isActive ? .bold : .regular))
                    .scaleEffect(isActive ? 1.1 : 1.0)
                    .foregroundStyle(
                        isActive
                            ? Color.ncPrimary
                            : Color.ncTextSecondary.opacity(0.65)
                    )
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.65),
                        value: isActive
                    )

                // Only show text for the active tab to reduce visual noise.
                if isActive {
                    Text(tab.title)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.ncPrimary)
                        .transition(
                            .opacity.combined(with: .scale(scale: 0.8, anchor: .top))
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    // MARK: - Floating Action Button
    private var fabButton: some View {
        Button {
            HapticManager.mediumTap()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                showAddMenu.toggle()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.ncPrimary.opacity(showAddMenu ? 0.22 : 0))
                    .frame(width: 76, height: 76)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "4ECDC4"), Color(hex: "2ECC9E")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .shadow(
                        color: Color.ncPrimary.opacity(showAddMenu ? 0.55 : 0.35),
                        radius: showAddMenu ? 18 : 10,
                        y: 4
                    )
                    .scaleEffect(showAddMenu ? 1.0 : (fabPulse ? 1.05 : 1.0))

                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(showAddMenu ? 45 : 0))
            }
            .animation(
                .spring(response: 0.45, dampingFraction: 0.72),
                value: showAddMenu
            )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .offset(y: -22)
        .accessibilityLabel(
            showAddMenu ? "Close quick actions" : "Open quick actions"
        )
    }

    // MARK: - Tab Bar Background
    private var tabBarBackground: some View {
        ZStack {
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(hex: "1E1F33").opacity(0.97))
                    .shadow(color: .black.opacity(0.45), radius: 28, y: -6)
            } else {
                RoundedRectangle(cornerRadius: 28)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.08), radius: 24, y: -5)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    colorScheme == .dark
                        ? Color.white.opacity(0.06)
                        : Color.white.opacity(0.55),
                    lineWidth: 0.5
                )
        )
    }
}

// MARK: - AddEntryMenu Overlay
struct AddEntryMenu: View {
    @Binding var isPresented: Bool

    @Environment(AppState.self)    private var appState
    @Environment(DataManager.self) private var dataManager

    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                ZStack {
                    Rectangle().fill(.ultraThinMaterial)
                    Rectangle().fill(Color.ncPrimary.opacity(0.04))
                }
                .ignoresSafeArea()
                .onTapGesture { dismiss() }
                .transition(.opacity)
            }

            if isPresented {
                VStack(spacing: 10) {
                    ForEach(Array(FABActionItem.all.enumerated()), id: \.element.id) { index, action in
                        actionRow(action: action, index: index)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 112)
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.72), value: isPresented)
        .allowsHitTesting(isPresented)
    }

    // MARK: - Action Row
    private func actionRow(action: FABActionItem, index: Int) -> some View {
        let appearDelay    = Double(index) * 0.05
        let dismissDelay   = Double(FABActionItem.all.count - 1 - index) * 0.04

        return Button {
            handleSelection(action.type)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: action.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(
                            color: action.gradient[0].opacity(0.45),
                            radius: 8,
                            y: 3
                        )

                    Image(systemName: action.icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text(action.label)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.ncText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.ncTextSecondary.opacity(0.45))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 44) // Fitts's Law
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.ncCard)
                    .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(action.gradient[0].opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(ScalePressButtonStyle())
        .accessibilityLabel(action.label)
        .animation(
            .spring(response: 0.45, dampingFraction: 0.72)
                .delay(isPresented ? appearDelay : dismissDelay),
            value: isPresented
        )
    }

    // MARK: - Selection Handler
    /// Routes selected FAB action to AppState after menu dismissal.
    private func handleSelection(_ type: DiaryEntryType) {
        HapticManager.mediumTap()
        let hasChildren = !dataManager.children.isEmpty

        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            isPresented = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            appState.triggerFAB(entryType: type, hasSelectedChild: hasChildren)
        }
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            isPresented = false
        }
    }
}

// MARK: - Preview
#Preview("Tab Bar") {
    ZStack {
        Color.ncBackground.ignoresSafeArea()
        VStack {
            Spacer()
            CustomTabBar(
                selectedTab: .constant(.diary),
                showAddMenu: .constant(false)
            )
            .padding(.horizontal, 12)
        }
    }
    .environment(AppState())
    .environment(DataManager.shared)
}

#Preview("FAB Menu Open") {
    ZStack {
        Color.ncBackground.ignoresSafeArea()
        AddEntryMenu(isPresented: .constant(true))
        VStack {
            Spacer()
            CustomTabBar(
                selectedTab: .constant(.diary),
                showAddMenu: .constant(true)
            )
            .padding(.horizontal, 12)
        }
    }
    .environment(AppState())
    .environment(DataManager.shared)
}
