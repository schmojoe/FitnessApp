import Foundation
import SwiftData

@Model
final class Workout {
    var title: String
    var date: Date
    var notes: String

    // The cascade rule ensures deleting a workout also deletes its associated exercises.
    // The inverse parameter links this back to the specific workout property in Exercise.
    @Relationship(deleteRule: .cascade, inverse: \Exercise.workout)
    var exercises: [Exercise]? = []

    init(title: String = "New Workout", date: Date = .now, notes: String = "") {
        self.title = title
        self.date = date
        self.notes = notes
    }
}
