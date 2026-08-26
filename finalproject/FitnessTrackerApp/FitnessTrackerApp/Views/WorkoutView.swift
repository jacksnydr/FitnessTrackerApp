//
//  WorkoutView.swift
//  FitnessTrackerApp
//
//  Team Members: Jack Snyder (snyderjk@iu.edu), Trevor Lough (tlough@iu.edu)
//  App Name: Fitness Tracker App
//  IU GitHub Submission Date: May 5, 2026
//

import SwiftUI

/// View for logging a new workout session with exercises and sets.
struct WorkoutView: View {
    @EnvironmentObject var vm: WorkoutViewModel
    @StateObject private var motionManager = MotionManager()

    @State private var exercises: [Exercise] = []
    @State private var showingSavedAlert = false
    @State private var isWorkoutActive = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Title
                Text("New Workout")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                // Motion Activity Banner
                if isWorkoutActive {
                    HStack {
                        Image(systemName: "figure.run")
                        VStack(alignment: .leading) {
                            Text(motionManager.currentActivity)
                                .font(.subheadline)
                            Text("Steps: \(motionManager.stepCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(12)
                }

                // Exercises
                ForEach($exercises) { $exercise in
                    ExerciseCard(exercise: $exercise)
                }

                // Add Exercise Button
                Button(action: {
                    exercises.append(Exercise(name: "", sets: []))
                    HapticManager.shared.playSuccess()

                    // Start motion tracking on first exercise
                    if !isWorkoutActive {
                        isWorkoutActive = true
                        motionManager.startStepCounting()
                        motionManager.startActivityUpdates()
                    }
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Exercise")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                // Save Workout Button
                Button(action: {
                    // Stop motion updates before saving to avoid concurrent UI updates
                    motionManager.stopStepCounting()
                    motionManager.stopActivityUpdates()
                    isWorkoutActive = false

                    // Persist via ViewModel (which triggers haptics and save on main actor)
                    vm.addWorkout(exercises: exercises)

                    // Reset local state after save
                    exercises = []
                    // Slight delay to let the list update settle before showing the alert
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        showingSavedAlert = true
                    }
                }) {
                    Text("Save Workout")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(exercises.isEmpty || exercises.allSatisfy { $0.sets.isEmpty })
                .opacity(exercises.isEmpty || exercises.allSatisfy { $0.sets.isEmpty } ? 0.5 : 1.0)
                .padding(.bottom)
            }
            .padding()
        }
        .alert("Workout Saved!", isPresented: $showingSavedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your workout has been saved and will appear in History.")
        }
    }
}

/// Reusable card view for a single exercise with its sets.
struct ExerciseCard: View {
    @Binding var exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            TextField("Exercise Name", text: $exercise.name)
                .textFieldStyle(.roundedBorder)
                .font(.headline)

            // Sets
            ForEach($exercise.sets) { $set in
                SetRow(set: $set)
            }

            // Add Set
            Button {
                exercise.sets.append(SetEntry(reps: 0, weight: 0))
                HapticManager.shared.playTap()
            } label: {
                Label("Add Set", systemImage: "plus.circle")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/// Row for entering a single set's reps and weight.
struct SetRow: View {
    @Binding var set: SetEntry

    var body: some View {
        HStack {
            Text("Set")
                .frame(width: 40, alignment: .leading)

            TextField("Reps", value: $set.reps, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)

            Text("reps")
                .foregroundColor(.secondary)
                .font(.caption)

            TextField("Weight", value: $set.weight, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)

            Text("lbs")
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
}
