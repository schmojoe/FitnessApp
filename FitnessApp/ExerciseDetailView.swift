import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    @Bindable var exercise: Exercise

    var body: some View {
        Form {
            Section("Exercise Name") {
                TextField("Name (e.g., Bench Press)", text: $exercise.name)
            }

            Section("Sets and Reps") {
                Stepper("Sets: \(exercise.sets)", value: $exercise.sets, in: 1...20)
                Stepper("Reps: \(exercise.reps)", value: $exercise.reps, in: 1...100)
            }

            Section("Weight") {
                HStack {
                    TextField("Weight", value: $exercise.weight, format: .number)
                        .keyboardType(.decimalPad)
                    Text("lbs/kg")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Edit Exercise")
        .navigationBarTitleDisplayMode(.inline)
    }
}
