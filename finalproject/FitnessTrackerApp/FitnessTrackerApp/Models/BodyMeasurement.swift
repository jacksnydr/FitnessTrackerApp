//
//  BodyMeasurement.swift
//  FitnessTrackerApp
//
//  Team Members: Jack Snyder (snyderjk@iu.edu), Trevor Lough (tlough@iu.edu)
//  App Name: Fitness Tracker App
//  IU GitHub Submission Date: May 5, 2026
//

import Foundation

/// A body measurement entry storing weight and optional body composition metrics.
struct BodyMeasurement: Identifiable, Codable {
    let id: UUID
    var date: Date
    var weight: Double
    var bodyFat: Double?
    var chest: Double?
    var waist: Double?
    var arms: Double?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        weight: Double,
        bodyFat: Double? = nil,
        chest: Double? = nil,
        waist: Double? = nil,
        arms: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.weight = weight
        self.bodyFat = bodyFat
        self.chest = chest
        self.waist = waist
        self.arms = arms
    }
}
