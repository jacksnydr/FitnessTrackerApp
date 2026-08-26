//
//  ProgressView.swift
//  FitnessTrackerApp
//
//  Team Members: Jack Snyder (snyderjk@iu.edu), Trevor Lough (tlough@iu.edu)
//  App Name: Fitness Tracker App
//  IU GitHub Submission Date: May 5, 2026
//

import SwiftUI
import Charts

/// Displays progress charts for a selected exercise over time using Swift Charts.
struct ProgressView: View {
    @EnvironmentObject var workoutVM: WorkoutViewModel
    @StateObject var progressVM = ProgressViewModel()

    @State private var selectedExercise: String = ""
    @State private var showingPicker = false

    var exerciseNames: [String] {
        progressVM.allExerciseNames(from: workoutVM.workouts)
    }

    var progressData: [ProgressPoint] {
        progressVM.getProgressData(for: selectedExercise, workouts: workoutVM.workouts)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {

                    // Exercise Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Exercise")
                            .font(.headline)

                        if exerciseNames.isEmpty {
                            Text("Log workouts to track progress.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Picker("Exercise", selection: $selectedExercise) {
                                ForEach(exerciseNames, id: \.self) { name in
                                    Text(name).tag(name)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.horizontal)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .onAppear {
                                if selectedExercise.isEmpty, let first = exerciseNames.first {
                                    selectedExercise = first
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Chart
                    if progressData.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "chart.xyaxis.line")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("No data for \"\(selectedExercise)\"")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Max Weight Over Time")
                                .font(.headline)
                                .padding(.horizontal)

                            Chart(progressData) { point in
                                LineMark(
                                    x: .value("Date", point.date),
                                    y: .value("Weight (lbs)", point.weight)
                                )
                                .foregroundStyle(Color.blue)

                                PointMark(
                                    x: .value("Date", point.date),
                                    y: .value("Weight (lbs)", point.weight)
                                )
                                .foregroundStyle(Color.blue)
                            }
                            .frame(height: 280)
                            .padding()
                            .chartYAxisLabel("lbs")
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                        // Summary
                        if let max = progressData.map({ $0.weight }).max(),
                           let min = progressData.map({ $0.weight }).min() {
                            HStack(spacing: 16) {
                                SummaryTile(label: "Best", value: "\(max) lbs", color: .green)
                                SummaryTile(label: "Starting", value: "\(min) lbs", color: .blue)
                                SummaryTile(label: "Sessions", value: "\(progressData.count)", color: .orange)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Progress")
        }
    }
}

/// Small summary tile used in the progress view.
struct SummaryTile: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .bold()
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
