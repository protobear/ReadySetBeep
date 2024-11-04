//
//  RunStore.swift
//  ReadySetBeep
//
//  Created by Marnick De Grave on 03/11/2024.
//

import Foundation

class RunStore: ObservableObject {
    @Published var runs: [Run] = []

    private let runsKey = "savedRuns"

    init() {
        loadRuns()
    }

    func loadRuns() {
        if let data = UserDefaults.standard.data(forKey: runsKey),
           let decodedRuns = try? JSONDecoder().decode([Run].self, from: data) {
            runs = decodedRuns
        }
    }

    func saveRuns() {
        if let data = try? JSONEncoder().encode(runs) {
            UserDefaults.standard.set(data, forKey: runsKey)
        }
    }

    func addRun(_ run: Run) {
        runs.append(run)
        saveRuns()
    }

    func deleteRun(at offsets: IndexSet) {
        runs.remove(atOffsets: offsets)
        saveRuns()
    }
}
