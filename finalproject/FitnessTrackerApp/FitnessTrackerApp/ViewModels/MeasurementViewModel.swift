//
//  MeasurementViewModel.swift
//  FitnessTrackerApp
//
//  Team Members: Jack Snyder (snyderjk@iu.edu), Trevor Lough (tlough@iu.edu)
//  App Name: Fitness Tracker App
//  IU GitHub Submission Date: May 5, 2026
//

import Foundation
import SwiftUI
import Combine

/// ViewModel managing body measurements, including persistent storage via UserDefaults.
class MeasurementViewModel: ObservableObject {
    @Published var measurements: [BodyMeasurement] = []

    private let storageKey = "saved_measurements"

    init() {
        loadMeasurements()
    }

    // MARK: - CRUD

    /// Adds a new measurement and saves to persistent storage.
    func addMeasurement(weight: Double, bodyFat: Double?, chest: Double? = nil, waist: Double? = nil, arms: Double? = nil) {
        let measurement = BodyMeasurement(
            date: Date(),
            weight: weight,
            bodyFat: bodyFat,
            chest: chest,
            waist: waist,
            arms: arms
        )
        measurements.append(measurement)
        HapticManager.shared.playTap()
        saveMeasurements()
    }

    /// Deletes measurements at the specified offsets.
    func deleteMeasurement(at offsets: IndexSet) {
        measurements.remove(atOffsets: offsets)
        saveMeasurements()
    }

    /// Returns measurements sorted by date ascending.
    func sortedMeasurements() -> [BodyMeasurement] {
        return measurements.sorted { $0.date < $1.date }
    }

    // MARK: - Persistence

    /// Encodes measurements to JSON and saves to UserDefaults.
    func saveMeasurements() {
        do {
            let encoded = try JSONEncoder().encode(measurements)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            print("Failed to save measurements: \(error.localizedDescription)")
        }
    }

    /// Loads and decodes measurements from UserDefaults.
    func loadMeasurements() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            measurements = try JSONDecoder().decode([BodyMeasurement].self, from: data)
        } catch {
            print("Failed to load measurements: \(error.localizedDescription)")
        }
    }
}
