//
//  Workout.swift
//  FitnessTrackerApp
//
//  Team Members: Jack Snyder (snyderjk@iu.edu), Trevor Lough (tlough@iu.edu)
//  App Name: Fitness Tracker App
//  IU GitHub Submission Date: May 5, 2026
//

import Foundation

/// A single workout session containing a date and list of exercises.
struct Workout: Identifiable, Codable {
    let id: UUID
    var date: Date
    var exercises: [Exercise]

    init(id: UUID = UUID(), date: Date = Date(), exercises: [Exercise]) {
        self.id = id
        self.date = date
        self.exercises = exercises
    }
}
