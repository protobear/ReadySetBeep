//
//  SettingsView.swift
//  ReadySetBeep
//
//  Created by Marnick De Grave on 03/11/2024.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var runStore: RunStore
    @State private var runName: String = ""

    // Input fields with empty default values
    @State private var runMinutes: String = ""
    @State private var runSeconds: String = ""
    @State private var walkMinutes: String = ""
    @State private var walkSeconds: String = ""
    @State private var totalDurationMinutes: String = ""
    @State private var isTotalRunningTime: Bool = false
    @State private var beepVolume: Double = 0.5
    @State private var numberOfBeeps: Int = 3

    @State private var navigateToTimer = false
    @State private var settings: IntervalSettings? = nil

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                // Run Name Section
                Section(header: Text("Run Name")) {
                    TextField("Enter a name for this run", text: $runName)
                }

                // Run/Walk Ratio Section
                Section(header: Text("Run/Walk Ratio")) {
                    HStack {
                        Text("Run Duration")
                        Spacer()
                        HStack(spacing: 0) {
                            TextField("Min", text: $runMinutes)
                                .keyboardType(.numberPad)
                                .frame(width: 50)
                                .multilineTextAlignment(.center)
                            Text("min")
                                .foregroundColor(.secondary)
                        }
                        HStack(spacing: 0) {
                            TextField("Sec", text: $runSeconds)
                                .keyboardType(.numberPad)
                                .frame(width: 50)
                                .multilineTextAlignment(.center)
                            Text("sec")
                                .foregroundColor(.secondary)
                        }
                    }
                    HStack {
                        Text("Walk Duration")
                        Spacer()
                        HStack(spacing: 0) {
                            TextField("Min", text: $walkMinutes)
                                .keyboardType(.numberPad)
                                .frame(width: 50)
                                .multilineTextAlignment(.center)
                            Text("min")
                                .foregroundColor(.secondary)
                        }
                        HStack(spacing: 0) {
                            TextField("Sec", text: $walkSeconds)
                                .keyboardType(.numberPad)
                                .frame(width: 50)
                                .multilineTextAlignment(.center)
                            Text("sec")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Total Session Duration Section
                Section(header: Text("Total Session Duration")) {
                    Toggle(isOn: $isTotalRunningTime) {
                        Text(isTotalRunningTime ? "Total Running Time" : "Total Time")
                    }
                    HStack {
                        Text("Duration")
                        Spacer()
                        HStack(spacing: 0) {
                            TextField("Minutes", text: $totalDurationMinutes)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.center)
                            Text("min")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Beep Settings Section
                Section(header: Text("Beep Settings")) {
                    HStack {
                        Text("Number of Beeps")
                        Spacer()
                        Stepper(value: $numberOfBeeps, in: 1...5) {
                            Text("\(numberOfBeeps)")
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("Beep Volume")
                        Slider(value: $beepVolume)
                    }
                }

                // Start Session Button
                Section {
                    Button(action: {
                        if isInputValid {
                            settings = collectSettings()
                            let run = Run(name: runName.isEmpty ? "Untitled Run" : runName, settings: settings!)
                            runStore.addRun(run)
                            navigateToTimer = true
                        } else {
                            alertMessage = "Please ensure all durations are greater than zero."
                            showAlert = true
                        }
                    }) {
                        Text("Start Session")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(isInputValid ? .blue : .gray)
                    }
                    .disabled(!isInputValid)
                }
            }
            .navigationTitle("New Run")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                self.presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationDestination(isPresented: $navigateToTimer) {
                if let validSettings = settings {
                    TimerView(settings: validSettings)
                } else {
                    EmptyView()
                }
            }
        }
    }

    @Environment(\.presentationMode) var presentationMode

    var isInputValid: Bool {
        guard
            let runMin = Double(runMinutes),
            let runSec = Double(runSeconds),
            let walkMin = Double(walkMinutes),
            let walkSec = Double(walkSeconds),
            let totalMin = Double(totalDurationMinutes),
            runMin >= 0,
            runSec >= 0,
            walkMin >= 0,
            walkSec >= 0,
            totalMin > 0,
            (runMin > 0 || runSec > 0),  // Run duration > 0
            (walkMin > 0 || walkSec > 0)  // Walk duration > 0
        else {
            return false
        }
        return true
    }

    func collectSettings() -> IntervalSettings {
        return IntervalSettings(
            runDuration: convertToSeconds(minutes: runMinutes, seconds: runSeconds),
            walkDuration: convertToSeconds(minutes: walkMinutes, seconds: walkSeconds),
            totalDuration: (Double(totalDurationMinutes) ?? 0) * 60,
            isTotalRunningTime: isTotalRunningTime,
            beepVolume: Float(beepVolume),
            numberOfBeeps: numberOfBeeps
        )
    }

    func convertToSeconds(minutes: String, seconds: String) -> TimeInterval {
        let min = Double(minutes) ?? 0
        let sec = Double(seconds) ?? 0
        return (min * 60) + sec
    }
}
