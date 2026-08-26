//
//  MainTabView.swift
//  FitnessTrackerApp
//
//  Team Members: Jack Snyder (snyderjk@iu.edu), Trevor Lough (tlough@iu.edu)
//  App Name: Fitness Tracker App
//  IU GitHub Submission Date: May 5, 2026
//

import SwiftUI

/// Root tab view providing navigation between the five main sections of the app.
struct MainTabView: View {
    var body: some View {
        TabView {
            WorkoutView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Workout")
                }

            HistoryView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("History")
                }

            ProgressView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Progress")
                }

            MeasurementView()
                .tabItem {
                    Image(systemName: "scalemass.fill")
                    Text("Body")
                }

            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Analytics")
                }
        }
    }
}
