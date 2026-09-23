import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    @Bindable var workout: Workout
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Form {
            Section("Workout Details") {
                TextField("Title", text: $workout.title)
                DatePicker("Date", selection: $workout.date)
            }

            Section("Notes") {
                TextField("Add notes here...", text: $workout.notes, axis: .vertical)
            }

            Section("Exercises") {
                ForEach(workout.exercises?.sorted(by: { $0.orderIndex < $1.orderIndex }) ?? []) { exercise in
                    NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                        HStack {
                            Text(exercise.name.isEmpty ? "New Exercise" : exercise.name)
                            Spacer()
                            Text("\(exercise.sets)x\(exercise.reps) @ \(exercise.weight.formatted())")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            deleteExercise(exercise)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }

                Button(action: addExercise) {
                    Label("Add Exercise", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Edit Workout")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func addExercise() {
        withAnimation {
            let currentCount = workout.exercises?.count ?? 0
            let newExercise = Exercise(name: "New Exercise", orderIndex: currentCount)

            newExercise.workout = workout
            workout.exercises = (workout.exercises ?? []) + [newExercise]
            modelContext.insert(newExercise)
        }
    }

    private func deleteExercise(_ exercise: Exercise) {
        withAnimation {
            modelContext.delete(exercise)
        }
    }
}
