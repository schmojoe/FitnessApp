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
                Picker("Type", selection: $workout.workoutType) {
                    Text("Strength").tag("Strength")
                    Text("Cardio").tag("Cardio")
                }
                if !workout.programName.isEmpty {
                    LabeledContent("Program", value: workout.programName)
                }
            }

            if workout.workoutType == "Cardio" {
                Section("Cardio") {
                    Picker("Activity", selection: $workout.cardioType) {
                        ForEach(["Running", "Biking", "Walking", "Swimming", "Other"], id: \.self) { activity in
                            Text(activity)
                        }
                    }
                    HStack {
                        TextField("Distance", value: $workout.distance, format: .number.precision(.fractionLength(0...2)))
                            .keyboardType(.decimalPad)
                        Picker("Unit", selection: $workout.distanceUnit) {
                            Text("mi").tag("mi")
                            Text("km").tag("km")
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 140)
                    }
                    TextField("Duration (minutes)", value: $workout.durationMinutes, format: .number.precision(.fractionLength(0...1)))
                        .keyboardType(.decimalPad)
                }
            } else {
                Section("Exercises") {
                    Picker("Weight unit", selection: $workout.weightUnit) {
                        Text("lbs").tag("lbs")
                        Text("kg").tag("kg")
                    }
                    .pickerStyle(.segmented)

                    ForEach(sortedExercises) { exercise in
                        NavigationLink {
                            ExerciseDetailView(exercise: exercise)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(exercise.name.isEmpty ? "Exercise" : exercise.name)
                                    .font(.headline)
                                Text("\(exercise.loggedSets?.count ?? exercise.sets) sets · \(exercise.reps) rep goal")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                modelContext.delete(exercise)
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

            Section("Notes") {
                TextField("Add notes here...", text: $workout.notes, axis: .vertical)
                    .lineLimit(3...8)
            }
        }
        .navigationTitle("Edit Workout")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var sortedExercises: [Exercise] {
        (workout.exercises ?? []).sorted { $0.orderIndex < $1.orderIndex }
    }

    private func addExercise() {
        let exercise = Exercise(name: "", orderIndex: workout.exercises?.count ?? 0)
        let sets = (0..<exercise.sets).map { index in
            ExerciseSet(reps: exercise.reps, weight: exercise.weight, orderIndex: index)
        }
        exercise.loggedSets = sets
        exercise.setsInitialized = true
        exercise.workout = workout
        workout.exercises = (workout.exercises ?? []) + [exercise]
        modelContext.insert(exercise)
    }
}
