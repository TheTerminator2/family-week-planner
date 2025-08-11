import SwiftUI
import SwiftData

struct PlannerView: View {
    @Environment(\.modelContext) private var context
    @AppStorage("defaultWeeklyTarget") private var defaultWeeklyTarget: Int = 5
    @AppStorage("startHour") private var startHour: Int = 8
    @AppStorage("endHour") private var endHour: Int = 18
    var household: Household { WeekService.shared.ensureHousehold(in: context) }
    var body: some View {
        let key = WeekService.shared.currentWeekKey()
        let plan = WeekService.shared.ensureWeekPlan(for: key, household: household, targetCount: defaultWeeklyTarget, in: context)
        VStack(alignment: .leading) {
            HStack { Text("Planlæg uge \(plan.week), \(plan.year)").font(.title2).bold(); Spacer(); ShareHouseholdButton() }.padding(.bottom, 8)
            List {
                Section("Vælg opgaver og tildel barn") {
                    if household.library.isEmpty { Text("Opret/importér opgaver under 'Opgaver'.").foregroundStyle(.secondary) }
                    else if household.members.isEmpty { Text("Tilføj børn under 'Børn & mål'.").foregroundStyle(.secondary) }
                    else {
                        ForEach(household.library) { tpl in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(tpl.title)
                                    if let d = tpl.details, !d.isEmpty { Text(d).font(.caption).foregroundStyle(.secondary) }
                                }
                                Spacer()
                                Menu("Tildel") {
                                    ForEach(household.members) { m in
                                        Button(m.name) {
                                            plan.tasks.append(WeeklyTask(title: tpl.title, details: tpl.details, category: tpl.category, isDone: false, templateId: tpl.id, assignee: m))
                                            try? context.save()
                                        }
                                    }
                                }.buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
                if !plan.tasks.isEmpty {
                    Section("Ugens opgaver") {
                        ForEach(plan.tasks) { t in
                            HStack {
                                Button {
                                    t.isDone.toggle(); t.completedAt = t.isDone ? Date() : nil; try? context.save()
                                    if household.members.allSatisfy({ m in plan.tasks.filter { $0.assignee?.id == m.id && $0.isDone }.count >= m.targetPerWeek }) {
                                        NotificationManager.shared.cancelEndOfWeekWarning(weekKey: plan.weekKey)
                                    }
                                } label: { Image(systemName: t.isDone ? "checkmark.circle.fill" : "circle").imageScale(.large) }
                                VStack(alignment: .leading) { Text(t.title); if let a = t.assignee { Text("→ \(a.name)").font(.caption).foregroundStyle(.secondary) } }
                                Spacer()
                                Button(role: .destructive) {
                                    if let i = plan.tasks.firstIndex(where: { $0.id == t.id }) { plan.tasks.remove(at: i); try? context.save() }
                                } label: { Image(systemName: "trash") }
                            }
                        }
                    }
                }
                Section("Notifikationer") {
                    Button { scheduleNotifications(for: plan) } label: { Label("Planlæg notifikationer", systemImage: "bell.badge") }.buttonStyle(.borderedProminent)
                    Text("Starter mandag kl. \(startHour). Advarsel søndag kl. \(endHour).").font(.footnote).foregroundStyle(.secondary)
                }
            }
        }.padding()
    }
    private func scheduleNotifications(for plan: WeekPlan) {
        let cal = Calendar.iso8601; let now = Date()
        let mon = cal.nextDate(after: now, matching: DateComponents(weekday: 2, hour: startHour, minute: 0), matchingPolicy: .nextTimePreservingSmallerComponents) ?? now
        let monC = cal.dateComponents([.weekday,.hour,.minute], from: mon)
        let titles = plan.tasks.map { "\($0.assignee?.name ?? ""): \($0.title)" }
        NotificationManager.shared.scheduleStartOfWeekReminder(weekKey: plan.weekKey, dateComponents: monC, taskTitles: titles)
        let sun = cal.nextDate(after: now, matching: DateComponents(weekday: 1, hour: endHour, minute: 0), matchingPolicy: .nextTimePreservingSmallerComponents) ?? now
        let sunC = cal.dateComponents([.weekday,.hour,.minute], from: sun)
        NotificationManager.shared.scheduleEndOfWeekWarning(weekKey: plan.weekKey, dateComponents: sunC)
    }
}
