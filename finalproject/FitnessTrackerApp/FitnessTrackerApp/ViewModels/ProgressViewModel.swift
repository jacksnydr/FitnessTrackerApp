//
//  ProgressViewModel.swift
//  FitnessTrackerApp
//
//  Team Members: Jack Snyder (snyderjk@iu.edu), Trevor Lough (tlough@iu.edu)
//  App Name: Fitness Tracker App
//  IU GitHub Submission Date: May 5, 2026
//

import Foundation
import Combine

/// A single data point for an exercise's max weight on a given date.
struct ProgressPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Int
}

/// ViewModel for computing per-exercise progress data from workout history.
class ProgressViewModel: ObservableObject {

    /// Returns progress points (max weight per session) for the specified exercise name.
    func getProgressData(for exerciseName: String, workouts: [Workout]) -> [ProgressPoint] {
        var data: [ProgressPoint] = []

        for workout in workouts {
            for exercise in workout.exercises {
                if exercise.name.lowercased() == exerciseName.lowercased() {
                    let maxWeight = exercise.sets.map { $0.weight }.max() ?? 0
                    data.append(ProgressPoint(date: workout.date, weight: maxWeight))
                }
            }
        }

        return data.sorted { $0.date < $1.date }
    }

    /// Returns a sorted list of all unique exercise names across all workouts.
    func allExerciseNames(from workouts: [Workout]) -> [String] {
        let names = workouts.flatMap { $0.exercises.map { $0.name } }
        return Array(Set(names)).sorted()
    }
}
