//
//  AnalyticsViewModel.swift
//  FitnessTrackerApp
//
//  Team Members: Jack Snyder (snyderjk@iu.edu), Trevor Lough (tlough@iu.edu)
//  App Name: Fitness Tracker App
//  IU GitHub Submission Date: May 5, 2026
//

import Foundation
import Combine

/// ViewModel providing computed analytics over a list of workouts.
class AnalyticsViewModel: ObservableObject {

    /// Returns the total number of workouts logged.
    func totalWorkouts(_ workouts: [Workout]) -> Int {
        return workouts.count
    }

    /// Returns the name of the most frequently logged exercise, or "N/A" if none.
    func mostFrequentExercise(_ workouts: [Workout]) -> String {
        var freq: [String: Int] = [:]
        for workout in workouts {
            for exercise in workout.exercises {
                freq[exercise.name, default: 0] += 1
            }
        }
        return freq.max(by: { $0.value < $1.value })?.key ?? "N/A"
    }

    /// Returns a dictionary of exercise name to personal record (max weight ever).
    func personalRecords(_ workouts: [Workout]) -> [String: Int] {
        var records: [String: Int] = [:]
        for workout in workouts {
            for exercise in workout.exercises {
                let maxWeight = exercise.sets.map { $0.weight }.max() ?? 0
                records[exercise.name] = max(records[exercise.name] ?? 0, maxWeight)
            }
        }
        return records
    }

    /// Returns total training volume (sum of weight * reps across all workouts).
    func totalVolume(_ workouts: [Workout]) -> Int {
        return workouts.flatMap { $0.exercises }.flatMap { $0.sets }.reduce(0) {
            $0 + $1.weight * $1.reps
        }
    }

    /// Returns the current consecutive workout streak in days.
    func currentStreak(_ workouts: [Workout]) -> Int {
        let calendar = Calendar.current
        let uniqueDays: Set<Date> = Set(workouts.map { calendar.startOfDay(for: $0.date) })
        let sortedDays = uniqueDays.sorted(by: >)

        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        for day in sortedDays {
            if calendar.isDate(day, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else if day < currentDate {
                break
            }
        }
        return streak
    }

    /// Returns workout counts grouped by calendar day, sorted ascending.
    func workoutsPerDay(_ workouts: [Workout]) -> [(date: Date, count: Int)] {
        var dict: [Date: Int] = [:]
        let calendar = Calendar.current

        for workout in workouts {
            let day = calendar.startOfDay(for: workout.date)
            dict[day, default: 0] += 1
        }

        return dict.map { ($0.key, $0.value) }.sorted { $0.date < $1.date }
    }

    /// Returns the total number of individual sets logged across all workouts.
    func totalSets(_ workouts: [Workout]) -> Int {
        return workouts.flatMap { $0.exercises }.flatMap { $0.sets }.count
    }
}
