import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]

    var body: some View {
        NavigationStack {
            List {
                ForEach(workouts) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        VStack(alignment: .leading) {
                            Text(workout.title)
                                .font(.headline)
                            Text(workout.date, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            deleteWorkout(workout)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("My Workouts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: addWorkout) {
                        Label("Add Workout", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func addWorkout() {
        withAnimation {
            let newWorkout = Workout()
            modelContext.insert(newWorkout)
        }
    }

    private func deleteWorkout(_ workout: Workout) {
        withAnimation {
            modelContext.delete(workout)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Workout.self, Exercise.self], inMemory: true)
}
