import SwiftUI
import SwiftData

struct ProgramsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Program.startDate, order: .reverse) private var programs: [Program]

    var body: some View {
        NavigationStack {
            Group {
                if programs.isEmpty {
                    ContentUnavailableView(
                        "No Programs Yet",
                        systemImage: "calendar",
                        description: Text("Create a program to save a reusable weekly workout split.")
                    )
                } else {
                    List {
                        ForEach(programs) { program in
                            NavigationLink {
                                ProgramDetailView(program: program)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(program.title)
                                            .font(.headline)
                                        if program.isActive {
                                            Text("Active")
                                                .font(.caption2.weight(.semibold))
                                                .padding(.horizontal, 7)
                                                .padding(.vertical, 3)
                                                .background(.tint.opacity(0.14), in: Capsule())
                                        }
                                    }
                                    Text("\(program.workouts?.count ?? 0) planned workouts · Started \(program.startDate, format: .dateTime.month(.abbreviated).year())")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    modelContext.delete(program)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Programs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: addProgram) {
                        Label("New Program", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func addProgram() {
        let program = Program()
        modelContext.insert(program)
    }
}

private struct ProgramDetailView: View {
    @Bindable var program: Program
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Form {
            Section("Program") {
                TextField("Program name", text: $program.title)
                Toggle("Active", isOn: $program.isActive)
                DatePicker("Start date", selection: $program.startDate, displayedComponents: .date)
                Toggle("Set end date", isOn: Binding(
                    get: { program.endDate != nil },
                    set: { program.endDate = $0 ? .now : nil }
                ))
                if program.endDate != nil {
                    DatePicker("End date", selection: Binding(
                        get: { program.endDate ?? .now },
                        set: { program.endDate = $0 }
                    ), displayedComponents: .date)
                }
                TextField("Notes", text: $program.notes, axis: .vertical)
                    .lineLimit(2...6)
            }

            Section("Weekly Split") {
                ForEach(sortedWorkouts) { workoutPlan in
                    NavigationLink {
                        WorkoutPlanDetailView(workoutPlan: workoutPlan)
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(workoutPlan.title)
                                .font(.headline)
                            Text([workoutPlan.dayLabel, "\(workoutPlan.exercises?.count ?? 0) exercises"]
                                .filter { !$0.isEmpty }
                                .joined(separator: " · "))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            modelContext.delete(workoutPlan)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }

                Button(action: addWorkoutPlan) {
                    Label("Add Planned Workout", systemImage: "plus")
                }
            }
        }
        .navigationTitle(program.title.isEmpty ? "Program" : program.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var sortedWorkouts: [WorkoutPlan] {
        (program.workouts ?? []).sorted { $0.orderIndex < $1.orderIndex }
    }

    private func addWorkoutPlan() {
        let workoutPlan = WorkoutPlan(orderIndex: sortedWorkouts.count)
        workoutPlan.program = program
        program.workouts = (program.workouts ?? []) + [workoutPlan]
        modelContext.insert(workoutPlan)
    }
}

private struct WorkoutPlanDetailView: View {
    @Bindable var workoutPlan: WorkoutPlan
    @Environment(\.modelContext) private var modelContext
    @State private var activeWorkout: Workout?

    var body: some View {
        Form {
            Section("Workout") {
                TextField("Workout name", text: $workoutPlan.title)
                TextField("Day or schedule (e.g., Monday)", text: $workoutPlan.dayLabel)
                TextField("Notes", text: $workoutPlan.notes, axis: .vertical)
                    .lineLimit(2...5)
            }

            Section("Exercise Goals") {
                ForEach(sortedExercises) { exercise in
                    NavigationLink {
                        ExercisePlanDetailView(exercisePlan: exercise)
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(exercise.name.isEmpty ? "Exercise" : exercise.name)
                                .font(.headline)
                            Text("\(exercise.sets) sets · \(exercise.minReps)-\(exercise.maxReps) reps")
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
        .navigationTitle(workoutPlan.title.isEmpty ? "Planned Workout" : workoutPlan.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: logWorkout) {
                    Label("Log", systemImage: "play")
                }
                .disabled(workoutPlan.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .sheet(item: $activeWorkout) { workout in
            NavigationStack {
                WorkoutDetailView(workout: workout)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                activeWorkout = nil
                            }
                        }
                    }
            }
        }
    }

    private var sortedExercises: [ExercisePlan] {
        (workoutPlan.exercises ?? []).sorted { $0.orderIndex < $1.orderIndex }
    }

    private func addExercise() {
        let exercise = ExercisePlan(orderIndex: sortedExercises.count)
        exercise.workoutPlan = workoutPlan
        workoutPlan.exercises = (workoutPlan.exercises ?? []) + [exercise]
        modelContext.insert(exercise)
    }

    private func logWorkout() {
        let program = workoutPlan.program
        let workout = Workout(
            title: workoutPlan.title,
            workoutType: "Strength",
            programName: program?.title ?? ""
        )
        let exercises = sortedExercises.map { plannedExercise in
            let exercise = Exercise(
                name: plannedExercise.name,
                sets: plannedExercise.sets,
                reps: plannedExercise.maxReps,
                orderIndex: plannedExercise.orderIndex
            )
            let sets = (0..<max(plannedExercise.sets, 0)).map { index in
                ExerciseSet(reps: plannedExercise.maxReps, orderIndex: index)
            }
            exercise.loggedSets = sets
            exercise.setsInitialized = true
            exercise.workout = workout
            return exercise
        }
        workout.exercises = exercises
        modelContext.insert(workout)
        activeWorkout = workout
    }
}

private struct ExercisePlanDetailView: View {
    @Bindable var exercisePlan: ExercisePlan

    var body: some View {
        Form {
            Section("Exercise") {
                TextField("Name", text: $exercisePlan.name)
            }
            Section("Goals") {
                Stepper("Sets: \(exercisePlan.sets)", value: $exercisePlan.sets, in: 1...20)
                Stepper("Minimum reps: \(exercisePlan.minReps)", value: $exercisePlan.minReps, in: 1...100)
                Stepper("Maximum reps: \(exercisePlan.maxReps)", value: $exercisePlan.maxReps, in: exercisePlan.minReps...100)
            }
        }
        .navigationTitle(exercisePlan.name.isEmpty ? "Exercise Goal" : exercisePlan.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: exercisePlan.minReps) { _, minimum in
            exercisePlan.maxReps = max(exercisePlan.maxReps, minimum)
        }
    }
}
