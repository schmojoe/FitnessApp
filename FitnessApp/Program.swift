import Foundation
import SwiftData

@Model
final class Program {
    var title: String
    var startDate: Date
    var endDate: Date?
    var notes: String
    var isActive: Bool

    @Relationship(deleteRule: .cascade, inverse: \WorkoutPlan.program)
    var workouts: [WorkoutPlan]? = []

    init(title: String = "New Program", startDate: Date = .now, endDate: Date? = nil, notes: String = "", isActive: Bool = true) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.isActive = isActive
    }
}
