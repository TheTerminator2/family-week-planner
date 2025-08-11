import SwiftUI
import SwiftData

@main
struct FamilyWeekPlannerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Household.self, Member.self, TaskTemplate.self, WeekPlan.self, WeeklyTask.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .automatic)
        do { return try ModelContainer(for: schema, configurations: [config]) }
        catch { fatalError("Could not create ModelContainer: \(error)") }
    }()
    var body: some Scene {
        WindowGroup { ContentView().modelContainer(sharedModelContainer) }
    }
}
