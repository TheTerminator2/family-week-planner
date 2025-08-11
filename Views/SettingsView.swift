import SwiftUI
struct SettingsView: View {
    @AppStorage("defaultWeeklyTarget") private var defaultWeeklyTarget: Int = 5
    @AppStorage("startHour") private var startHour: Int = 8
    @AppStorage("endHour") private var endHour: Int = 18
    var body: some View {
        Form {
            Section("Ugemål (app-standard)") {
                Stepper("Antal opgaver/uge: \(defaultWeeklyTarget)", value: $defaultWeeklyTarget, in: 1...40)
                Text("Hvert barn har også sit eget mål (standard 2/uge) under 'Børn'.").font(.footnote).foregroundStyle(.secondary)
            }
            Section("Notifikationer") {
                Stepper("Start på ugen (kl.): \(startHour)", value: $startHour, in: 0...23)
                Stepper("Advarsel ved ugens slut (kl.): \(endHour)", value: $endHour, in: 0...23)
            }
            Section("iCloud deling") {
                Text("Tryk på 'Del familie' for at invitere familiemedlemmer via iCloud. Alle med invitation kan se og redigere opgaver.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }.navigationTitle("Indstillinger")
    }
}
