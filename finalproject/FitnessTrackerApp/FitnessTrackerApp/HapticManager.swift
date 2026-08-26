//
//  HapticManager.swift
//  FitnessTrackerApp
//
//  Team Members: Jack Snyder (snyderjk@iu.edu), Trevor Lough (tlough@iu.edu)
//  App Name: Fitness Tracker App
//  IU GitHub Submission Date: May 5, 2026
//

import Foundation
#if canImport(CoreHaptics)
import CoreHaptics

/// Singleton manager for CoreHaptics feedback throughout the app.
@available(iOS 13.0, *)
@MainActor
class HapticManager {
    static let shared = HapticManager()

    private var engine: CHHapticEngine?

    private init() {
        prepareHaptics()
    }

    /// Prepares the CoreHaptics engine for use.
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptics error: \(error.localizedDescription)")
        }
    }

    /// Plays a light tap feedback (e.g., for adding a set or measurement).
    func playTap() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        playOnMain {
            [
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        .init(parameterID: .hapticIntensity, value: 0.7),
                        .init(parameterID: .hapticSharpness, value: 0.7)
                    ],
                    relativeTime: 0
                )
            ]
        }
    }

    /// Plays a stronger success feedback (e.g., for adding an exercise).
    func playSuccess() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        playOnMain {
            [
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        .init(parameterID: .hapticIntensity, value: 1.0),
                        .init(parameterID: .hapticSharpness, value: 0.8)
                    ],
                    relativeTime: 0
                )
            ]
        }
    }

    /// Plays a double tap feedback (e.g., for saving a workout).
    func playDoubleTap() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        playOnMain {
            [
                CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0),
                CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.1)
            ]
        }
    }

    /// Ensures haptic playback is executed on the main actor.
    private func playOnMain(_ eventsProvider: @escaping () -> [CHHapticEvent]) {
        if Thread.isMainThread {
            let events = eventsProvider()
            playPattern(events: events)
        } else {
            DispatchQueue.main.async { [weak self] in
                let events = eventsProvider()
                self?.playPattern(events: events)
            }
        }
    }

    private func playPattern(events: [CHHapticEvent]) {
        do {
            if engine == nil {
                prepareHaptics()
            }
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error.localizedDescription)")
        }
    }
}
#else

// Fallback for platforms without CoreHaptics
@MainActor
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func playTap() {
        // No haptics available
    }
    
    func playSuccess() {
        // No haptics available
    }
    
    func playDoubleTap() {
        // No haptics available
    }
}

#endif

