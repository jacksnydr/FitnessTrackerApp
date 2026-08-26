//
//  FitnessTrackerApp.swift
//  FitnessTrackerApp
//
//  Team Members: Jack Snyder (snyderjk@iu.edu), Trevor Lough (tlough@iu.edu)
//  App Name: Fitness Tracker App
//  IU GitHub Submission Date: May 5, 2026
//

import SwiftUI

/// App entry point. Injects shared ViewModels into the environment.
@main
struct FitnessTrackerApp: App {
    @StateObject var workoutVM = WorkoutViewModel()
    @StateObject var measurementVM = MeasurementViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(workoutVM)
                .environmentObject(measurementVM)
        }
    }
}
