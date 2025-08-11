import SwiftUI
import CloudKit
import SwiftData

struct ShareHouseholdButton: View {
    @Environment(\.modelContext) private var context
    @Query private var households: [Household]
    @State private var showShare = false
    @State private var share: CKShare?
    var body: some View {
        Button {
            guard let household = households.first else { return }
            do {
                let result = try context.share([household], to: nil)
                if let ckShare = result.share {
                    ckShare[CKShare.SystemFieldKey.title] = "Familieplan"; self.share = ckShare; showShare = true
                }
            } catch { print("Share error: \(error)") }
        } label: { Label("Del familie", systemImage: "person.3") }
        .buttonStyle(.borderedProminent)
        .sheet(isPresented: $showShare) {
            if let share = share { CloudShareSheet(share: share, containerIdentifier: "iCloud.com.example.familyweekplanner") }
        }
    }
}
struct CloudShareSheet: UIViewControllerRepresentable {
    let share: CKShare; let containerIdentifier: String
    func makeUIViewController(context: Context) -> UICloudSharingController {
        UICloudSharingController(share: share, container: CKContainer(identifier: containerIdentifier))
    }
    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {}
}
