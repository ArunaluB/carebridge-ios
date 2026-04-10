// Main app container with tab content, FAB flow, and global toast handling.

import SwiftUI

struct ContentView: View {

    // MARK: - Environment
    @Environment(DataManager.self) var dataManager

    // MARK: - App-wide State
    @State private var appState = AppState()

    // MARK: - Tab State
    @State private var selectedTab: TabItem = .diary
    @State private var showAddMenu: Bool = false

    // MARK: - FAB ViewModel
    @State private var fabDiaryViewModel = DiaryViewModel()

    var body: some View {
        // Create local bindings for @Observable state.
        @Bindable var bindableAppState = appState

        return ZStack {
            Group {
                switch selectedTab {
                case .diary:
                    DailyDiaryView()
                case .addNew:
                    // FAB actions are handled via overlay; diary remains the base view.
                    DailyDiaryView()
                case .incidents:
                    IncidentListView()
                case .settings:
                    SettingsView()
                }
            }

            AddEntryMenu(isPresented: $showAddMenu)

            VStack(spacing: 0) {
                Spacer()
                CustomTabBar(
                    selectedTab: $selectedTab,
                    showAddMenu: $showAddMenu
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 0)
            }

            InAppToastBanner()
        }
        // Share AppState with tab bar and FAB components.
        .environment(appState)
        .ignoresSafeArea(.keyboard, edges: .bottom)

        // MARK: FAB Sheet
        .sheet(isPresented: $bindableAppState.showFABSheet, onDismiss: {
            appState.resetFABState()
        }) {
            fabEntrySheet
        }

        // MARK: Child Picker
        .sheet(isPresented: $bindableAppState.showChildPickerFirst) {
            FABChildPickerSheet(
                isPresented: $bindableAppState.showChildPickerFirst,
                onChildSelected: { child in
                    fabDiaryViewModel.selectedChildId = child.id
                    appState.showChildPickerFirst = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        appState.showFABSheet = true
                    }
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }

        .toast($bindableAppState.globalToast)

        .onAppear {
            fabDiaryViewModel.dataManager = dataManager
            if fabDiaryViewModel.selectedChildId == nil,
               let first = dataManager.children.first {
                fabDiaryViewModel.selectedChildId = first.id
            }
        }
        .onChange(of: appState.fabSelectedEntryType) { _, newType in
            if let type = newType {
                fabDiaryViewModel.prepareNewEntry(type: type)
            }
        }
    }

    // MARK: - FAB Entry Sheet
    @ViewBuilder
    private var fabEntrySheet: some View {
        DiaryEntryFormView(viewModel: fabDiaryViewModel)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .onDisappear {
                // Promote local save toast to app-level banner.
                if let toast = fabDiaryViewModel.toast {
                    appState.globalToast = toast
                    fabDiaryViewModel.toast = nil
                }
                appState.resetFABState()
            }
    }

}

// MARK: - FAB Child Picker Sheet
struct FABChildPickerSheet: View {
    @Binding var isPresented: Bool
    let onChildSelected: (ChildProfile) -> Void

    @Environment(DataManager.self) private var dataManager

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.ncTextSecondary.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            Text("Quick Log — Select Child")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.ncText)
                .padding(.top, 16)
                .padding(.bottom, 8)

            Divider().padding(.horizontal, 20)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(dataManager.children) { child in
                        Button {
                            HapticManager.selection()
                            onChildSelected(child)
                        } label: {
                            HStack(spacing: 14) {
                                ChildAvatar(child: child, size: 44)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(child.displayName)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color.ncText)
                                    Text(child.age + " · " + child.roomAssignment)
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundStyle(Color.ncTextSec)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.ncTextSecondary.opacity(0.4))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(minHeight: 44)
                            .cardStyle()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel("Select \(child.displayName)")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .background(Color.ncBackground)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environment(DataManager.shared)
        .environment(ThemeManager())
        .environment(SleepTrackerManager.shared)
}
