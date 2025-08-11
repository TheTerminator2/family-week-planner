import Foundation
import SwiftData

struct WeekKey { let year: Int; let week: Int; var string: String { "\(year)-W\(week)" } }
final class WeekService {
    static let shared = WeekService(); private init() {}
    func currentWeekKey(calendar: Calendar = .iso8601) -> WeekKey {
        let now = Date(); let c = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        return WeekKey(year: c.yearForWeekOfYear ?? 2000, week: c.weekOfYear ?? 1)
    }
    func ensureHousehold(named: String = "Familien", in context: ModelContext) -> Household {
        if let h = try? context.fetch(FetchDescriptor<Household>()).first { return h }
        let h = Household(name: named); context.insert(h); try? context.save(); return h
    }
    func ensureWeekPlan(for key: WeekKey, household: Household, targetCount: Int, in context: ModelContext) -> WeekPlan {
        let pred = #Predicate<WeekPlan> { $0.year == key.year && $0.week == key.week && $0.household?.id == household.id }
        if let p = try? context.fetch(FetchDescriptor<WeekPlan>(predicate: pred)).first { return p }
        let plan = WeekPlan(year: key.year, week: key.week, targetCount: targetCount, household: household)
        context.insert(plan); try? context.save(); return plan
    }
}
extension Calendar {
    static var iso8601: Calendar = { var c = Calendar(identifier: .iso8601); c.firstWeekday = 2; c.minimumDaysInFirstWeek = 4; return c }()
}
