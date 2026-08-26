//
//  Exercise.swift
//  FitnessTrackerApp
//
//  Team Members: Jack Snyder (snyderjk@iu.edu), Trevor Lough (tlough@iu.edu)
//  App Name: Fitness Tracker App
//  IU GitHub Submission Date: May 5, 2026
//

import Foundation

/// An exercise performed during a workout, consisting of a name and one or more sets.
struct Exercise: Identifiable, Codable {
    let id: UUID
    var name: String
    var sets: [SetEntry]

    init(id: UUID = UUID(), name: String, sets: [SetEntry]) {
        self.id = id
        self.name = name
        self.sets = sets
    }
}
