import Foundation
import SwiftData

@Model
final class WorkoutPlan {
    var title: String
    var dayLabel: String
    var orderIndex: Int
    var notes: String
    var program: Program?

    @Relationship(deleteRule: .cascade, inverse: \ExercisePlan.workoutPlan)
    var exercises: [ExercisePlan]? = []

    init(title: String = "New Workout", dayLabel: String = "", orderIndex: Int = 0, notes: String = "") {
        self.title = title
        self.dayLabel = dayLabel
        self.orderIndex = orderIndex
        self.notes = notes
    }
}

@Model
final class ExercisePlan {
    var name: String
    var sets: Int
    var minReps: Int
    var maxReps: Int
    var orderIndex: Int
    var workoutPlan: WorkoutPlan?

    init(name: String = "", sets: Int = 3, minReps: Int = 8, maxReps: Int = 12, orderIndex: Int = 0) {
        self.name = name
        self.sets = sets
        self.minReps = minReps
        self.maxReps = maxReps
        self.orderIndex = orderIndex
    }
}
