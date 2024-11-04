//
//  OverviewView.swift
//  ReadySetBeep
//
//  Created by Marnick De Grave on 03/11/2024.
//

import SwiftUI

struct OverviewView: View {
    @ObservedObject var runStore = RunStore()
    @State private var showOnboarding: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                if !runStore.runs.isEmpty {
                    // Buttons at the top
                    HStack {
                        if let lastRun = runStore.runs.last {
                            NavigationLink(destination: TimerView(settings: lastRun.settings)) {
                                Text("Repeat Last Run")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        NavigationLink(destination: SettingsView(runStore: runStore)) {
                            Text("Add New Run")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()

                    // List of saved runs
                    List {
                        ForEach(runStore.runs) { run in
                            NavigationLink(destination: TimerView(settings: run.settings)) {
                                VStack(alignment: .leading) {
                                    Text(run.name)
                                        .font(.headline)
                                    Text(run.date, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: runStore.deleteRun)
                    }
                } else {
                    // No runs saved
                    Text("No runs saved.")
                        .font(.headline)
                        .padding()

                    NavigationLink(destination: SettingsView(runStore: runStore)) {
                        Text("Add New Run")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Ready, Set, Beep!")
            .navigationBarItems(trailing: EditButton())
            .onAppear {
                if runStore.runs.isEmpty {
                    showOnboarding = true
                }
            }
            .sheet(isPresented: $showOnboarding) {
                OnboardingView(showOnboarding: $showOnboarding)
            }
        }
    }
}
