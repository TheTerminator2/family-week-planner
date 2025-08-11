import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import CoreXLSX

struct TasksLibraryView: View {
    @Environment(\.modelContext) private var context
    var household: Household { WeekService.shared.ensureHousehold(in: context) }
    @State private var showImporter = false
    @State private var importType: ImportType = .csv
    enum ImportType: String, CaseIterable, Identifiable { case csv = "CSV", xlsx = "XLSX"; var id: String { rawValue } }
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Opgavebibliotek").font(.title2).bold(); Spacer()
                Menu {
                    Button("Importér CSV") { importType = .csv; showImporter = true }
                    Button("Importér XLSX") { importType = .xlsx; showImporter = true }
                } label: { Label("Importér", systemImage: "square.and.arrow.down") }.buttonStyle(.borderedProminent)
            }
            List {
                Section("Eksisterende (\(household.library.count))") {
                    ForEach(household.library) { t in
                        VStack(alignment: .leading) {
                            Text(t.title).font(.body.bold())
                            if let d = t.details, !d.isEmpty { Text(d).font(.caption).foregroundStyle(.secondary) }
                        }
                    }.onDelete { idx in idx.forEach { context.delete(household.library[$0]) }; try? context.save() }
                }
                Section("Opret ny") { NewTaskRow(household: household) }
            }
        }.padding()
        .fileImporter(isPresented: $showImporter, allowedContentTypes: importType == .csv ? [UTType.commaSeparatedText, .text] : [UTType.xlsx]) { result in
            switch result {
            case .success(let url): if importType == .csv { importCSV(url: url) } else { importXLSX(url: url) }
            case .failure(let e): print("Import error: \(e)")
            }
        }
    }
    func importCSV(url: URL) {
        guard let data = try? Data(contentsOf: url), let str = String(data: data, encoding: .utf8) else { return }
        let lines = str.split(whereSeparator: \.isNewline).dropFirst()
        for r in lines {
            let c = r.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            if c.isEmpty { continue }
            let title = c.indices.contains(0) ? c[0] : ""
            let details = c.indices.contains(1) ? c[1] : nil
            let category = c.indices.contains(2) ? c[2] : nil
            let minutes = c.indices.contains(3) ? Int(c[3]) ?? 15 : 15
            if !title.isEmpty { household.library.append(TaskTemplate(title: title, details: details, category: category, defaultDurationMinutes: minutes)) }
        }
        try? context.save()
    }
    func importXLSX(url: URL) {
        do {
            let file = try XLSXFile(filepath: url.path); guard let ss = try file.parseSharedStrings() else { return }
            for wb in try file.parseWorkbooks() {
                for (_, path) in try file.parseWorksheetPathsAndNames(workbook: wb) {
                    if let ws = try file.parseWorksheet(at: path) {
                        for row in ws.data?.rows.dropFirst() ?? [] {
                            let v = row.cells.compactMap { $0.stringValue(ss) }
                            let title = v.indices.contains(0) ? v[0] : ""
                            let details = v.indices.contains(1) ? v[1] : nil
                            let category = v.indices.contains(2) ? v[2] : nil
                            let minutes = v.indices.contains(3) ? Int(v[3]) ?? 15 : 15
                            if !title.isEmpty { household.library.append(TaskTemplate(title: title, details: details, category: category, defaultDurationMinutes: minutes)) }
                        }
                    }
                }
            }
            try? context.save()
        } catch { print("XLSX import error: \(error)") }
    }
}
struct NewTaskRow: View {
    @Environment(\.modelContext) private var context
    var household: Household
    @State private var title = ""; @State private var details = ""; @State private var category = ""; @State private var minutes = 15
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Titel", text: $title); TextField("Detaljer (valgfri)", text: $details)
            HStack { TextField("Kategori (valgfri)", text: $category); Stepper("Varighed \(minutes)m", value: $minutes, in: 1...240).labelsHidden() }
            HStack {
                Button("Tilføj") {
                    guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    household.library.append(TaskTemplate(title: title, details: details.isEmpty ? nil : details, category: category.isEmpty ? nil : category, defaultDurationMinutes: minutes)); try? context.save()
                    title=""; details=""; category=""; minutes=15
                }.buttonStyle(.borderedProminent)
                Button("Ryd") { title=""; details=""; category=""; minutes=15 }
            }
        }
    }
}
