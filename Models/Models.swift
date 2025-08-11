import Foundation
import SwiftData

@Model final class Household {
    @Attribute(.unique) var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade) var members: [Member] = []
    @Relationship(deleteRule: .cascade) var weekPlans: [WeekPlan] = []
    @Relationship(deleteRule: .cascade) var library: [TaskTemplate] = []
    init(id: UUID = UUID(), name: String) { self.id = id; self.name = name }
}
@Model final class Member {
    @Attribute(.unique) var id: UUID
    var name: String
    var targetPerWeek: Int
    init(id: UUID = UUID(), name: String, targetPerWeek: Int = 2) {
        self.id = id; self.name = name; self.targetPerWeek = targetPerWeek
    }
}
@Model final class TaskTemplate {
    @Attribute(.unique) var id: UUID
    var title: String; var details: String?; var category: String?; var defaultDurationMinutes: Int
    init(id: UUID = UUID(), title: String, details: String? = nil, category: String? = nil, defaultDurationMinutes: Int = 15) {
        self.id = id; self.title = title; self.details = details; self.category = category; self.defaultDurationMinutes = defaultDurationMinutes
    }
}
@Model final class WeekPlan {
    @Attribute(.unique) var id: UUID
    var year: Int; var week: Int; var createdAt: Date; var targetCount: Int
    @Relationship(deleteRule: .cascade) var tasks: [WeeklyTask] = []
    var household: Household?
    init(id: UUID = UUID(), year: Int, week: Int, createdAt: Date = Date(), targetCount: Int, household: Household?) {
        self.id = id; self.year = year; self.week = week; self.createdAt = createdAt; self.targetCount = targetCount; self.household = household
    }
    var weekKey: String { "\(year)-W\(week)" }
}
@Model final class WeeklyTask {
    @Attribute(.unique) var id: UUID
    var title: String; var details: String?; var category: String?
    var isDone: Bool; var completedAt: Date?; var templateId: UUID?; var assignee: Member?
    init(id: UUID = UUID(), title: String, details: String? = nil, category: String? = nil, isDone: Bool = false, completedAt: Date? = nil, templateId: UUID? = nil, assignee: Member? = nil) {
        self.id = id; self.title = title; self.details = details; self.category = category; self.isDone = isDone; self.completedAt = completedAt; self.templateId = templateId; self.assignee = assignee
    }
}
