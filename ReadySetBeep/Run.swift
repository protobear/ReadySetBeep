//
//  Run.swift
//  ReadySetBeep
//
//  Created by Marnick De Grave on 03/11/2024.
//

import Foundation

struct Run: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var settings: IntervalSettings
    var date: Date = Date()
}
