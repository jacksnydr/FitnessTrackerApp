//
//  SetEntry.swift
//  FitnessTrackerApp
//
//  Team Members: Jack Snyder (snyderjk@iu.edu), Trevor Lough (tlough@iu.edu)
//  App Name: Fitness Tracker App
//  IU GitHub Submission Date: May 5, 2026
//

import Foundation

/// A single set within an exercise, storing reps and weight.
struct SetEntry: Identifiable, Codable {
    let id: UUID
    var reps: Int
    var weight: Int

    init(id: UUID = UUID(), reps: Int, weight: Int) {
        self.id = id
        self.reps = reps
        self.weight = weight
    }
}
