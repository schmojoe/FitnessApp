import Foundation
import SwiftData

@Model
final class Workout {
    var title: String
    var date: Date
    var notes: String
    var workoutType: String = "Strength"
    var cardioType: String = "Running"
    var distance: Double = 0
    var distanceUnit: String = "mi"
    var durationMinutes: Double = 0
    var programName: String = ""
    var weightUnit: String = "lbs"

    @Relationship(deleteRule: .cascade, inverse: \Exercise.workout)
    var exercises: [Exercise]? = []

    init(
        title: String = "New Workout",
        date: Date = .now,
        notes: String = "",
        workoutType: String = "Strength",
        cardioType: String = "Running",
        distance: Double = 0,
        distanceUnit: String = "mi",
        durationMinutes: Double = 0,
        programName: String = "",
        weightUnit: String = "lbs"
    ) {
        self.title = title
        self.date = date
        self.notes = notes
        self.workoutType = workoutType
        self.cardioType = cardioType
        self.distance = distance
        self.distanceUnit = distanceUnit
        self.durationMinutes = durationMinutes
        self.programName = programName
        self.weightUnit = weightUnit
    }
}
