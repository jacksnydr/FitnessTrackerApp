//
//  AnalyticsView.swift
//  FitnessTrackerApp
//
//  Team Members: Jack Snyder (snyderjk@iu.edu), Trevor Lough (tlough@iu.edu)
//  App Name: Fitness Tracker App
//  IU GitHub Submission Date: May 5, 2026
//

import SwiftUI
import CoreGraphics

/// Displays aggregate analytics and stats for all logged workouts.
struct AnalyticsView: View {
    @EnvironmentObject var workoutVM: WorkoutViewModel
    @StateObject var analyticsVM = AnalyticsViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {

                    // Summary Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {

                        AnalyticsCard(
                            title: "Workouts",
                            value: "\(analyticsVM.totalWorkouts(workoutVM.workouts))",
                            icon: "figure.strengthtraining.traditional",
                            color: .blue
                        )

                        let streak = analyticsVM.currentStreak(workoutVM.workouts)
                        AnalyticsCard(
                            title: "Streak",
                            value: streak == 0 ? "Start Today" : "\(streak) days 🔥",
                            icon: "flame",
                            color: .orange
                        )

                        AnalyticsCard(
                            title: "Total Volume",
                            value: "\(analyticsVM.totalVolume(workoutVM.workouts)) lbs",
                            icon: "scalemass",
                            color: .green
                        )

                        AnalyticsCard(
                            title: "Total Sets",
                            value: "\(analyticsVM.totalSets(workoutVM.workouts))",
                            icon: "list.number",
                            color: .purple
                        )
                    }

                    // Frequency Graph
                    let freqData = analyticsVM.workoutsPerDay(workoutVM.workouts)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Workout Frequency")
                            .font(.headline)
                            .padding(.horizontal)
                        WorkoutFrequencyGraph(data: freqData)
                    }

                    // Top Exercise
                    let topEx = analyticsVM.mostFrequentExercise(workoutVM.workouts)
                    if topEx != "N/A" {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                            VStack(alignment: .leading) {
                                Text("Most Frequent Exercise")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(topEx)
                                    .font(.headline)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    // Personal Records
                    let prs = analyticsVM.personalRecords(workoutVM.workouts)
                    if !prs.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Personal Records")
                                .font(.headline)

                            ForEach(prs.keys.sorted(), id: \.self) { key in
                                HStack {
                                    Text(key)
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(prs[key] ?? 0) lbs")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics")
        }
    }
}

/// Card used in the analytics grid.
struct AnalyticsCard: View {
    var title: String
    var value: String
    var icon: String
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.title2)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

/// CoreGraphics line graph showing workout frequency per day.
struct WorkoutFrequencyGraph: View {
    var data: [(date: Date, count: Int)]

    var body: some View {
        GeometryReader { geo in
            if data.count < 2 {
                Text("Not enough data to display graph")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                let maxY = data.map { $0.count }.max() ?? 1
                let width = geo.size.width
                let height = geo.size.height

                ZStack {
                    // Grid
                    ForEach(0..<4) { i in
                        let y = height * CGFloat(i) / 3
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: width, y: y))
                        }
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    }

                    // Fill
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: height))
                        for i in data.indices {
                            let x = width * CGFloat(i) / CGFloat(data.count - 1)
                            let yRatio = Double(data[i].count) / Double(maxY)
                            let y = height - CGFloat(yRatio) * height
                            if i == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.green, lineWidth: 3)

                    // Dots
                    ForEach(data.indices, id: \.self) { i in
                        let x = width * CGFloat(i) / CGFloat(data.count - 1)
                        let yRatio = Double(data[i].count) / Double(maxY)
                        let y = height - CGFloat(yRatio) * height
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .position(x: x, y: y)
                    }
                }
            }
        }
        .frame(height: 200)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
