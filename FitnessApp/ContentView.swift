import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            WorkoutsView()
                .tabItem {
                    Label("Workouts", systemImage: "dumbbell")
                }

            ProgramsView()
                .tabItem {
                    Label("Programs", systemImage: "calendar")
                }
        }
    }
}

private struct WorkoutsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]

    var body: some View {
        NavigationStack {
            Group {
                if workouts.isEmpty {
                    ContentUnavailableView(
                        "No Workouts Yet",
                        systemImage: "dumbbell",
                        description: Text("Log a workout to start tracking your progress.")
                    )
                } else {
                    List {
                        ForEach(workouts) { workout in
                            NavigationLink {
                                WorkoutDetailView(workout: workout)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(workout.title)
                                        .font(.headline)
                                    HStack(spacing: 8) {
                                        Text(workout.date, format: .dateTime.month(.abbreviated).day().year())
                                        Text(workout.workoutType)
                                        if !workout.programName.isEmpty {
                                            Text(workout.programName)
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    modelContext.delete(workout)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Workout Log")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            addWorkout(type: "Strength")
                        } label: {
                            Label("Strength Workout", systemImage: "dumbbell")
                        }
                        Button {
                            addWorkout(type: "Cardio")
                        } label: {
                            Label("Cardio Session", systemImage: "figure.run")
                        }
                    } label: {
                        Label("Log Workout", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func addWorkout(type: String) {
        let workout = Workout(title: type == "Cardio" ? "Cardio Session" : "Strength Workout", workoutType: type)
        modelContext.insert(workout)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Workout.self, Exercise.self, ExerciseSet.self, Program.self, WorkoutPlan.self, ExercisePlan.self], inMemory: true)
}
