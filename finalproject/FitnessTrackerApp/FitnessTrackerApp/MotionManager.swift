
//  MotionManager.swift
//  FitnessTrackerApp
//
//  Team Members: Jack Snyder (snyderjk@iu.edu), Trevor Lough (tlough@iu.edu)
//  App Name: Fitness Tracker App
//  IU GitHub Submission Date: May 5, 2026
//

import Foundation
import CoreMotion
import Combine

/// Manages CoreMotion step counting and activity data for the workout session.
class MotionManager: ObservableObject {
    private let pedometer = CMPedometer()
    private let activityManager = CMMotionActivityManager()

    @Published var stepCount: Int = 0
    @Published var currentActivity: String = "Unknown"
    @Published var isAvailable: Bool = CMPedometer.isStepCountingAvailable()

    // MARK: - Step Counting

    /// Starts real-time step counting from the current moment.
    func startStepCounting() {
        guard CMPedometer.isStepCountingAvailable() else { return }

        pedometer.startUpdates(from: Date()) { [weak self] data, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self?.stepCount = data.numberOfSteps.intValue
            }
        }
    }

    /// Stops the step counting pedometer updates.
    func stopStepCounting() {
        pedometer.stopUpdates()
    }

    // MARK: - Activity Recognition

    /// Starts motion activity updates to detect the current movement type.
    func startActivityUpdates() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            currentActivity = "Not available on simulator"
            return
        }

        activityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let activity = activity else { return }
            DispatchQueue.main.async {
                if activity.running {
                    self?.currentActivity = "Running 🏃"
                } else if activity.cycling {
                    self?.currentActivity = "Cycling 🚴"
                } else if activity.walking {
                    self?.currentActivity = "Walking 🚶"
                } else if activity.stationary {
                    self?.currentActivity = "Stationary 🧘"
                } else {
                    self?.currentActivity = "Active 💪"
                }
            }
        }
    }

    /// Stops activity updates.
    func stopActivityUpdates() {
        activityManager.stopActivityUpdates()
    }
}
