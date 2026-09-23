import Foundation
import SwiftData

@Model
final class Exercise {
    var name: String
    var sets: Int
    var reps: Int
    var weight: Double
    var orderIndex: Int

    var workout: Workout?

    init(name: String = "", sets: Int = 3, reps: Int = 10, weight: Double = 0.0, orderIndex: Int = 0) {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.orderIndex = orderIndex
    }
}
