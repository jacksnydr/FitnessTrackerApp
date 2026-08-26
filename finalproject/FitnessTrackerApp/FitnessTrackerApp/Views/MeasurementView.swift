//
//  MeasurementView.swift
//  FitnessTrackerApp
//
//  Team Members: Jack Snyder (snyderjk@iu.edu), Trevor Lough (tlough@iu.edu)
//  App Name: Fitness Tracker App
//  IU GitHub Submission Date: May 5, 2026
//

import SwiftUI
import CoreGraphics

/// View for logging and reviewing body measurements with a weight trend graph.
struct MeasurementView: View {
    @EnvironmentObject var vm: MeasurementViewModel

    @State private var weight = ""
    @State private var bodyFat = ""
    @State private var chest = ""
    @State private var waist = ""
    @State private var arms = ""
    @State private var showingExtra = false

    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {

                    // Input Card
                    VStack(spacing: 12) {
                        Text("Log Measurement")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        TextField("Weight (lbs) *", text: $weight)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .focused($isInputFocused)

                        TextField("Body Fat % (optional)", text: $bodyFat)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .focused($isInputFocused)

                        // Toggle extra measurements
                        Button(action: { showingExtra.toggle() }) {
                            HStack {
                                Text(showingExtra ? "Hide Extra Fields" : "Add More Measurements")
                                    .font(.caption)
                                Image(systemName: showingExtra ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                        }

                        if showingExtra {
                            TextField("Chest (in)", text: $chest)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .focused($isInputFocused)

                            TextField("Waist (in)", text: $waist)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .focused($isInputFocused)

                            TextField("Arms (in)", text: $arms)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .focused($isInputFocused)
                        }

                        Button(action: saveMeasurement) {
                            Text("Save Measurement")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(weight.isEmpty)
                        .opacity(weight.isEmpty ? 0.5 : 1.0)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 2)

                    // Weight Graph
                    if vm.sortedMeasurements().count >= 2 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weight Trend")
                                .font(.headline)
                                .padding(.horizontal)
                            WeightGraphView(measurements: vm.sortedMeasurements())
                        }
                    }

                    // Measurement History
                    if !vm.measurements.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("History")
                                .font(.headline)

                            ForEach(vm.measurements.sorted { $0.date > $1.date }) { m in
                                MeasurementRowView(measurement: m)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Measurements")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { isInputFocused = false }
                }
            }
        }
    }

    private func saveMeasurement() {
        let weightVal = Double(weight) ?? 0
        vm.addMeasurement(
            weight: weightVal,
            bodyFat: Double(bodyFat),
            chest: Double(chest),
            waist: Double(waist),
            arms: Double(arms)
        )
        isInputFocused = false
        weight = ""
        bodyFat = ""
        chest = ""
        waist = ""
        arms = ""
    }
}

/// Row displaying a single measurement entry.
struct MeasurementRowView: View {
    let measurement: BodyMeasurement

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(measurement.date, style: .date)
                .font(.headline)

            HStack(spacing: 16) {
                Label("\(measurement.weight, specifier: "%.1f") lbs", systemImage: "scalemass")
                    .font(.subheadline)

                if let bf = measurement.bodyFat {
                    Label("\(bf, specifier: "%.1f")%", systemImage: "percent")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            if measurement.chest != nil || measurement.waist != nil || measurement.arms != nil {
                HStack(spacing: 12) {
                    if let c = measurement.chest {
                        Text("Chest: \(c, specifier: "%.1f")\"").font(.caption).foregroundColor(.secondary)
                    }
                    if let w = measurement.waist {
                        Text("Waist: \(w, specifier: "%.1f")\"").font(.caption).foregroundColor(.secondary)
                    }
                    if let a = measurement.arms {
                        Text("Arms: \(a, specifier: "%.1f")\"").font(.caption).foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

/// CoreGraphics line graph for weight measurements over time.
struct WeightGraphView: View {
    var measurements: [BodyMeasurement]

    var body: some View {
        GeometryReader { geo in
            let data = measurements.sorted { $0.date < $1.date }

            if data.count < 2 {
                Text("Not enough data")
                    .foregroundColor(.gray)
            } else {
                let weights = data.map { $0.weight }
                let minY = (weights.min() ?? 0) - 2
                let maxY = (weights.max() ?? 1) + 2
                let range = maxY - minY
                let width = geo.size.width
                let height = geo.size.height

                ZStack {
                    // Grid lines
                    ForEach(0..<5) { i in
                        let y = height * CGFloat(i) / 4
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: width, y: y))
                        }
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    }

                    // Line
                    Path { path in
                        for i in data.indices {
                            let x = width * CGFloat(i) / CGFloat(data.count - 1)
                            let yRatio = (data[i].weight - minY) / range
                            let y = height - CGFloat(yRatio) * height
                            if i == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.blue, lineWidth: 3)

                    // Dots
                    ForEach(data.indices, id: \.self) { i in
                        let x = width * CGFloat(i) / CGFloat(data.count - 1)
                        let yRatio = (data[i].weight - minY) / range
                        let y = height - CGFloat(yRatio) * height
                        Circle()
                            .fill(Color.blue)
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
