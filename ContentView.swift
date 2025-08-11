import SwiftUI
struct ContentView: View {
    @State private var tab = 0
    var body: some View {
        TabView(selection: $tab) {
            DashboardView().tabItem { Label("Dashboard", systemImage: "speedometer") }.tag(0)
            PlannerView().tabItem { Label("Ugeplan", systemImage: "calendar") }.tag(1)
            TasksLibraryView().tabItem { Label("Opgaver", systemImage: "checklist") }.tag(2)
            MembersView().tabItem { Label("Børn", systemImage: "person.2") }.tag(3)
            SettingsView().tabItem { Label("Indstillinger", systemImage: "gearshape") }.tag(4)
        }
    }
}
