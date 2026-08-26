//
//  HistoryView.swift
//  FitnessTrackerApp
//
//  Team Members: Jack Snyder (snyderjk@iu.edu), Trevor Lough (tlough@iu.edu)
//  App Name: Fitness Tracker App
//  IU GitHub Submission Date: May 5, 2026
//

import SwiftUI

/// Displays the full history of logged workouts with swipe-to-delete support.
struct HistoryView: View {
    @EnvironmentObject var vm: WorkoutViewModel

    var sortedWorkouts: [Workout] {
        vm.workouts.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationView {
            Group {
                if vm.workouts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No workouts yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Add a workout to see it here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(sortedWorkouts) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                WorkoutRowView(workout: workout)
                            }
                        }
                        .onDelete(perform: deleteWorkout)
                    }
                    .transaction { $0.animation = nil }
                }
            }
            .navigationTitle("History")
            .toolbar {
                EditButton()
            }
        }
    }

    /// Finds the original index in unsorted array and deletes.
    private func deleteWorkout(at offsets: IndexSet) {
        // Map the offsets from the sorted array back to the original indices
        let sorted = sortedWorkouts
        let originalIndices: [Int] = offsets.compactMap { offset in
            let workout = sorted[offset]
            return vm.workouts.firstIndex(where: { $0.id == workout.id })
        }
        // Convert to an IndexSet and delegate deletion to the ViewModel
        let indexSet = IndexSet(originalIndices)
        vm.deleteWorkout(at: indexSet)
    }
}

/// Summary row for a single workout in the history list.
struct WorkoutRowView: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(workout.date, style: .date)
                .font(.headline)
            Text("\(workout.exercises.count) exercise\(workout.exercises.count == 1 ? "" : "s")")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

/// Detailed view showing all exercises and sets for a workout.
struct WorkoutDetailView: View {
    let workout: Workout

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text(workout.date, style: .date)
                    .font(.title2)
                    .bold()
                    .padding(.top)

                ForEach(workout.exercises) { exercise in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.name)
                            .font(.headline)

                        ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                            HStack {
                                Text("Set \(index + 1)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 50, alignment: .leading)
                                Text("\(set.reps) reps @ \(set.weight) lbs")
                                    .font(.body)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

