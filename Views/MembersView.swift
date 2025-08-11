import SwiftUI
import SwiftData

struct MembersView: View {
    @Environment(\.modelContext) private var context
    @State private var newName = ""; @State private var newTarget = 2
    var household: Household { WeekService.shared.ensureHousehold(in: context) }
    var body: some View {
        VStack(alignment: .leading) {
            HStack { Text("Børn & mål").font(.title2).bold(); Spacer(); ShareHouseholdButton() }
            List {
                Section("Tilføj barn") {
                    HStack {
                        TextField("Navn", text: $newName)
                        Stepper("Mål \(newTarget)/uge", value: $newTarget, in: 1...20).labelsHidden()
                        Button("Tilføj") {
                            guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            household.members.append(Member(name: newName, targetPerWeek: newTarget)); try? context.save()
                            newName = ""; newTarget = 2
                        }.buttonStyle(.borderedProminent)
                    }
                }
                Section("Eksisterende") {
                    ForEach(household.members) { m in
                        HStack {
                            Text(m.name); Spacer()
                            Stepper("Mål \(m.targetPerWeek)", value: Binding(get: { m.targetPerWeek }, set: { m.targetPerWeek = $0; try? context.save() }), in: 1...20).labelsHidden()
                        }
                    }.onDelete { idx in idx.forEach { context.delete(household.members[$0]) }; try? context.save() }
                }
            }
        }.padding()
    }
}
