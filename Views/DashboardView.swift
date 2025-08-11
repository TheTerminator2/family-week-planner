import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @AppStorage("defaultWeeklyTarget") private var defaultWeeklyTarget: Int = 5
    @Query private var households: [Household]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack { Text("Familie-dashboard").font(.title).bold(); Spacer(); ShareHouseholdButton() }
                if let (household, plan) = currentContext {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(household.name).font(.headline)
                        Text("Uge \(plan.week) – \(plan.year)").foregroundStyle(.secondary)
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Børnenes fremdrift").font(.headline)
                        ForEach(household.members) { m in
                            let done = plan.tasks.filter { $0.assignee?.id == m.id && $0.isDone }.count
                            let total = plan.tasks.filter { $0.assignee?.id == m.id }.count
                            let aheadBehind = done - m.targetPerWeek
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(m.name).font(.body.bold())
                                    Text("Udført \(done) / Mål \(m.targetPerWeek) • Valgt \(total)").font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(aheadBehind >= 0 ? "Foran +\(aheadBehind)" : "Bagud \(aheadBehind)")
                                    .font(.caption).padding(6)
                                    .background((aheadBehind >= 0 ? Color.green.opacity(0.2) : Color.red.opacity(0.2)), in: Capsule())
                            }
                            ProgressView(value: total == 0 ? 0 : Double(done) / Double(max(total, m.targetPerWeek))).progressViewStyle(.linear)
                        }
                    }
                    let done = plan.tasks.filter { $0.isDone }.count
                    VStack(alignment: .leading, spacing: 8) {
                        HStack { Text("Ugens fremdrift").font(.headline); Spacer(); Text("\(done)/\(plan.tasks.count)") }
                        ProgressView(value: plan.tasks.isEmpty ? 0 : Double(done)/Double(plan.tasks.count))
                    }.padding().background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                } else {
                    Text("Opret husstand og ugeplan under 'Børn' og 'Ugeplan'.").foregroundStyle(.secondary)
                }
            }.padding()
        }.onAppear {
            let h = WeekService.shared.ensureHousehold(in: context)
            _ = WeekService.shared.ensureWeekPlan(for: WeekService.shared.currentWeekKey(), household: h, targetCount: defaultWeeklyTarget, in: context)
        }
    }
    private var currentContext: (Household, WeekPlan)? {
        guard let h = households.first else { return nil }
        let key = WeekService.shared.currentWeekKey()
        let pred = #Predicate<WeekPlan> { $0.year == key.year && $0.week == key.week && $0.household?.id == h.id }
        return (try? context.fetch(FetchDescriptor<WeekPlan>(predicate: pred)).first).map { (h, $0) }
    }
}
