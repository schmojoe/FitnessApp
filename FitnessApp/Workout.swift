import Foundation
import SwiftData

@Model
final class Workout {
    var title: String
    var date: Date
    var notes: String

    @Relationship(deleteRule: .cascade, inverse: \Exercise.workout)
    var exercises: [Exercise]? = []

    init(title: String = "New Workout", date: Date = .now, notes: String = "") {
        self.title = title
        self.date = date
        self.notes = notes
    }
}
