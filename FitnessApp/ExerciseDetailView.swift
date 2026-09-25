import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    @Bindable var exercise: Exercise
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Form {
            Section("Exercise") {
                TextField("Name (e.g., Bench Press)", text: $exercise.name)
            }

            Section {
                ForEach(sortedSets) { set in
                    ExerciseSetRow(set: set) {
                        deleteSet(set)
                    }
                }
                .onMove(perform: moveSets)

                Button(action: addSet) {
                    Label("Add Set", systemImage: "plus")
                }
            } header: {
                Text("Completed Sets")
            } footer: {
                Text("Enter the reps and weight used for each completed set.")
            }
        }
        .navigationTitle(exercise.name.isEmpty ? "Exercise" : exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton()
        }
        .onAppear(perform: initializeLegacySets)
    }

    private var sortedSets: [ExerciseSet] {
        (exercise.loggedSets ?? []).sorted { $0.orderIndex < $1.orderIndex }
    }

    private func initializeLegacySets() {
        guard !exercise.setsInitialized else { return }
        let sets = (0..<max(exercise.sets, 0)).map { index in
            ExerciseSet(reps: exercise.reps, weight: exercise.weight, orderIndex: index)
        }
        exercise.loggedSets = sets
        exercise.setsInitialized = true
        for set in sets {
            set.exercise = exercise
            modelContext.insert(set)
        }
    }

    private func addSet() {
        let set = ExerciseSet(reps: exercise.reps, weight: exercise.weight, orderIndex: sortedSets.count)
        set.exercise = exercise
        exercise.setsInitialized = true
        exercise.loggedSets = (exercise.loggedSets ?? []) + [set]
        modelContext.insert(set)
    }

    private func deleteSet(_ set: ExerciseSet) {
        exercise.loggedSets?.removeAll { $0.id == set.id }
        modelContext.delete(set)
        renumberSets()
    }

    private func moveSets(from source: IndexSet, to destination: Int) {
        var sets = sortedSets
        sets.move(fromOffsets: source, toOffset: destination)
        updateSetOrder(sets)
    }

    private func renumberSets() {
        updateSetOrder(sortedSets)
    }

    private func updateSetOrder(_ sets: [ExerciseSet]) {
        for (index, set) in sets.enumerated() {
            set.orderIndex = index
        }
    }
}

private struct ExerciseSetRow: View {
    @Bindable var set: ExerciseSet
    let delete: () -> Void

    var body: some View {
        HStack {
            Text("Set \(set.orderIndex + 1)")
                .frame(width: 48, alignment: .leading)
            Stepper("Reps: \(set.reps)", value: $set.reps, in: 0...100)
            TextField("Weight", value: $set.weight, format: .number.precision(.fractionLength(0...2)))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 74)
            Text(set.exercise?.workout?.weightUnit ?? "lbs")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .swipeActions {
            Button(role: .destructive, action: delete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
