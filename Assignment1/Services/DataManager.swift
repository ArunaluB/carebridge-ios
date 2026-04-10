// DataManager.swift
// NurseryConnect
// Central data manager backed by SwiftData local persistence.
// Uses a single persisted snapshot model to keep existing app-facing APIs unchanged.

import Foundation
import SwiftUI
import SwiftData

@Observable
class DataManager {
    static let shared = DataManager()
    
    // MARK: - Stored Data
    var keyworker: KeyworkerProfile
    var children: [ChildProfile]
    var diaryEntries: [DiaryEntry]
    var incidents: [Incident]
    var persistenceMode: String = "SwiftData (on-device)"
    var persistenceWarning: String?

    // MARK: - SwiftData
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }
    
    // MARK: - UserDefaults Keys
    private let keyworkerKey = "nc_keyworker"
    private let childrenKey = "nc_children"
    private let diaryEntriesKey = "nc_diary_entries"
    private let incidentsKey = "nc_incidents"
    private let hasLaunchedKey = "nc_has_launched_before"
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private struct StoredState {
        let keyworker: KeyworkerProfile
        let children: [ChildProfile]
        let diaryEntries: [DiaryEntry]
        let incidents: [Incident]
    }
    
    var hasLaunchedBefore: Bool {
        get { UserDefaults.standard.bool(forKey: hasLaunchedKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasLaunchedKey) }
    }
    
    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601

        if let primaryContainer = try? ModelContainer(for: PersistedAppStore.self) {
            container = primaryContainer
            persistenceMode = "SwiftData (on-device)"
        } else if let fallbackContainer = try? ModelContainer(
            for: PersistedAppStore.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ) {
            container = fallbackContainer
            persistenceMode = "SwiftData (in-memory fallback)"
            persistenceWarning = "Persistent storage is unavailable. Changes will reset when the app restarts."
        } else {
            preconditionFailure("Failed to initialize local data storage")
        }

        // Initialize with sample values first, then overwrite from persisted data if available.
        self.keyworker = SampleData.keyworker
        self.children = SampleData.children
        self.diaryEntries = SampleData.generateDiaryEntries()
        self.incidents = SampleData.generateIncidents()

        if let persistedStore = fetchPersistedStore(),
           let persistedState = decodeState(from: persistedStore) {
            self.keyworker = persistedState.keyworker
            self.children = persistedState.children
            self.diaryEntries = persistedState.diaryEntries
            self.incidents = persistedState.incidents
        } else if let legacyState = loadLegacyUserDefaultsState() {
            self.keyworker = legacyState.keyworker
            self.children = legacyState.children
            self.diaryEntries = legacyState.diaryEntries
            self.incidents = legacyState.incidents
        }

        // Ensure state is present and up to date in SwiftData after init.
        save()
    }
    
    // MARK: - Persistence
    func save() {
        do {
            let store = upsertStore()
            store.keyworkerData = try encoder.encode(keyworker)
            store.childrenData = try encoder.encode(children)
            store.diaryEntriesData = try encoder.encode(diaryEntries)
            store.incidentsData = try encoder.encode(incidents)
            store.updatedAt = Date()
            try context.save()
        } catch {
            persistenceWarning = "Latest changes could not be written to local storage."
            print("Failed to save SwiftData state: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Diary Entry CRUD
    func addDiaryEntry(_ entry: DiaryEntry) {
        diaryEntries.insert(entry, at: 0)
        save()
    }
    
    func updateDiaryEntry(_ entry: DiaryEntry) {
        if let index = diaryEntries.firstIndex(where: { $0.id == entry.id }) {
            diaryEntries[index] = entry
            save()
        }
    }
    
    func deleteDiaryEntry(_ entry: DiaryEntry) {
        diaryEntries.removeAll { $0.id == entry.id }
        save()
    }
    
    func diaryEntriesForChild(_ childId: UUID, on date: Date = Date()) -> [DiaryEntry] {
        let startOfDay = date.startOfDay
        let endOfDay = date.endOfDay
        return diaryEntries
            .filter { $0.childId == childId && $0.timestamp >= startOfDay && $0.timestamp <= endOfDay }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    func todayEntriesForChild(_ childId: UUID) -> [DiaryEntry] {
        return diaryEntriesForChild(childId, on: Date())
    }
    
    func recentEntriesForChild(_ childId: UUID, limit: Int = 5) -> [DiaryEntry] {
        return diaryEntries
            .filter { $0.childId == childId }
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Incident CRUD
    func addIncident(_ incident: Incident) {
        incidents.insert(incident, at: 0)
        save()
    }
    
    func updateIncident(_ incident: Incident) {
        if let index = incidents.firstIndex(where: { $0.id == incident.id }) {
            incidents[index] = incident
            save()
        }
    }
    
    func deleteIncident(_ incident: Incident) {
        incidents.removeAll { $0.id == incident.id }
        save()
    }
    
    func incidentsForChild(_ childId: UUID) -> [Incident] {
        return incidents
            .filter { $0.childId == childId }
            .sorted { $0.dateTime > $1.dateTime }
    }
    
    func todayIncidents() -> [Incident] {
        let startOfDay = Date().startOfDay
        return incidents.filter { $0.dateTime >= startOfDay }
            .sorted { $0.dateTime > $1.dateTime }
    }
    
    func pendingReviewIncidents() -> [Incident] {
        return incidents
            .filter { $0.status == .submitted || $0.status == .underReview }
            .sorted { $0.dateTime > $1.dateTime }
    }
    
    // MARK: - Child Helpers
    func child(for id: UUID) -> ChildProfile? {
        children.first { $0.id == id }
    }
    
    func childrenWithAllergies() -> [ChildProfile] {
        children.filter { !$0.allergies.isEmpty }
    }
    
    // MARK: - Statistics
    func todayActivityCount(for childId: UUID) -> Int {
        todayEntriesForChild(childId).filter { $0.type == .activity }.count
    }
    
    func todayMealCount(for childId: UUID) -> Int {
        todayEntriesForChild(childId).filter { $0.type == .meal }.count
    }
    
    func weekIncidentCount() -> Int {
        let startOfWeek = Date().startOfWeek
        return incidents.filter { $0.dateTime >= startOfWeek }.count
    }
    
    func totalEntriesThisWeek() -> Int {
        let startOfWeek = Date().startOfWeek
        return diaryEntries.filter { $0.timestamp >= startOfWeek }.count
    }
    
    // MARK: - Daily Summary
    func generateDailySummary(for childId: UUID, on date: Date = Date()) -> DailySummary {
        let entries = diaryEntriesForChild(childId, on: date)
        let child = child(for: childId)
        
        let activities = entries.filter { $0.type == .activity }
        let meals = entries.filter { $0.type == .meal }
        let sleeps = entries.filter { $0.type == .sleep }
        let nappies = entries.filter { $0.type == .nappy }
        let wellbeings = entries.filter { $0.type == .wellbeing }
        
        let totalSleepMinutes = sleeps.reduce(0) { total, entry in
            if let dur = entry.sleepDurationMinutes { return total + dur }
            return total
        }
        
        return DailySummary(
            childName: child?.fullName ?? "Unknown",
            date: date,
            activityCount: activities.count,
            mealCount: meals.count,
            sleepCount: sleeps.count,
            totalSleepMinutes: totalSleepMinutes,
            nappyCount: nappies.count,
            wellbeingChecks: wellbeings.count,
            latestMood: wellbeings.last?.moodRating ?? .content,
            entries: entries
        )
    }
    
    // MARK: - Reset Data
    func resetToSampleData() {
        keyworker = SampleData.keyworker
        children = SampleData.children
        diaryEntries = SampleData.generateDiaryEntries()
        incidents = SampleData.generateIncidents()
        save()
    }

    // MARK: - Private Helpers
    private static func sampleState() -> StoredState {
        StoredState(
            keyworker: SampleData.keyworker,
            children: SampleData.children,
            diaryEntries: SampleData.generateDiaryEntries(),
            incidents: SampleData.generateIncidents()
        )
    }

    private func decodeState(from store: PersistedAppStore) -> StoredState? {
        do {
            let keyworker = try decoder.decode(KeyworkerProfile.self, from: store.keyworkerData)
            let children = try decoder.decode([ChildProfile].self, from: store.childrenData)
            let diaryEntries = try decoder.decode([DiaryEntry].self, from: store.diaryEntriesData)
            let incidents = try decoder.decode([Incident].self, from: store.incidentsData)

            return StoredState(
                keyworker: keyworker,
                children: children,
                diaryEntries: diaryEntries,
                incidents: incidents
            )
        } catch {
            return nil
        }
    }

    private func loadLegacyUserDefaultsState() -> StoredState? {
        let defaults = UserDefaults.standard
        let hasLegacyData = [keyworkerKey, childrenKey, diaryEntriesKey, incidentsKey].contains {
            defaults.data(forKey: $0) != nil
        }

        guard hasLegacyData else { return nil }

        let keyworker = decodeWithFallback(
            defaults.data(forKey: keyworkerKey),
            as: KeyworkerProfile.self,
            fallback: SampleData.keyworker
        )
        let children = decodeWithFallback(
            defaults.data(forKey: childrenKey),
            as: [ChildProfile].self,
            fallback: SampleData.children
        )
        let diaryEntries = decodeWithFallback(
            defaults.data(forKey: diaryEntriesKey),
            as: [DiaryEntry].self,
            fallback: SampleData.generateDiaryEntries()
        )
        let incidents = decodeWithFallback(
            defaults.data(forKey: incidentsKey),
            as: [Incident].self,
            fallback: SampleData.generateIncidents()
        )

        return StoredState(
            keyworker: keyworker,
            children: children,
            diaryEntries: diaryEntries,
            incidents: incidents
        )
    }

    private func decodeWithFallback<T: Decodable>(_ data: Data?, as type: T.Type, fallback: T) -> T {
        guard let data, let decoded = try? decoder.decode(type, from: data) else {
            return fallback
        }
        return decoded
    }

    private func fetchPersistedStore() -> PersistedAppStore? {
        do {
            let stores = try context.fetch(FetchDescriptor<PersistedAppStore>())
            if let primary = stores.first(where: { $0.storeId == PersistedAppStore.defaultStoreId }) {
                return primary
            }
            if let firstStore = stores.first {
                firstStore.storeId = PersistedAppStore.defaultStoreId
                return firstStore
            }
            return nil
        } catch {
            return nil
        }
    }

    private func upsertStore() -> PersistedAppStore {
        if let existingStore = fetchPersistedStore() {
            return existingStore
        }
        let newStore = PersistedAppStore(storeId: PersistedAppStore.defaultStoreId)
        context.insert(newStore)
        return newStore
    }
}

@Model
final class PersistedAppStore {
    static let defaultStoreId = "primary"

    @Attribute(.unique) var storeId: String
    var keyworkerData: Data
    var childrenData: Data
    @Attribute(.externalStorage) var diaryEntriesData: Data
    @Attribute(.externalStorage) var incidentsData: Data
    var updatedAt: Date

    init(
        storeId: String,
        keyworkerData: Data = Data(),
        childrenData: Data = Data(),
        diaryEntriesData: Data = Data(),
        incidentsData: Data = Data(),
        updatedAt: Date = Date()
    ) {
        self.storeId = storeId
        self.keyworkerData = keyworkerData
        self.childrenData = childrenData
        self.diaryEntriesData = diaryEntriesData
        self.incidentsData = incidentsData
        self.updatedAt = updatedAt
    }
}

// MARK: - Daily Summary Model
struct DailySummary {
    let childName: String
    let date: Date
    let activityCount: Int
    let mealCount: Int
    let sleepCount: Int
    let totalSleepMinutes: Int
    let nappyCount: Int
    let wellbeingChecks: Int
    let latestMood: MoodRating
    let entries: [DiaryEntry]
    
    var totalSleepDuration: String {
        let hours = totalSleepMinutes / 60
        let minutes = totalSleepMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
