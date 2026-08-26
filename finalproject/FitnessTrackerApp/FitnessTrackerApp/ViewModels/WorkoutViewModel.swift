//
//  WorkoutViewModel.swift
//  FitnessTrackerApp
//
//  Team Members: Jack Snyder (snyderjk@iu.edu), Trevor Lough (tlough@iu.edu)
//  App Name: Fitness Tracker App
//  IU GitHub Submission Date: May 5, 2026
//

import Foundation
import SwiftUI
import Combine

@MainActor
/// ViewModel managing the list of workouts, including persistent storage via UserDefaults.
class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout] = []

    private let storageKey = "saved_workouts"

    init() {
        loadWorkouts()
    }

    // MARK: - CRUD

    /// Adds a new workout with the given exercises and saves to persistent storage.
    func addWorkout(exercises: [Exercise]) {
        let workout = Workout(date: Date(), exercises: exercises)
        workouts.append(workout)
        HapticManager.shared.playDoubleTap()
        saveWorkouts()
    }

    /// Deletes workouts at the specified offsets and saves changes.
    func deleteWorkout(at offsets: IndexSet) {
        workouts.remove(atOffsets: offsets)
        HapticManager.shared.playTap()
        saveWorkouts()
    }

    // MARK: - Persistence

    /// Encodes workouts array to JSON and saves to UserDefaults.
    func saveWorkouts() {
        assert(Thread.isMainThread, "saveWorkouts() must be called on the main thread")
        do {
            let encoded = try JSONEncoder().encode(workouts)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            print("Failed to save workouts: \(error.localizedDescription)")
        }
    }

    /// Loads and decodes workouts from UserDefaults.
    func loadWorkouts() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([Workout].self, from: data)
            if Thread.isMainThread {
                workouts = decoded
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.workouts = decoded
                }
            }
        } catch {
            print("Failed to load workouts: \(error.localizedDescription)")
        }
    }
}
