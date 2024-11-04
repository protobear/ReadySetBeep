//
//  Models.swift
//  ReadySetBeep
//
//  Created by Marnick De Grave on 03/11/2024.
//

import Foundation

struct IntervalSettings: Codable {
    var runDuration: TimeInterval // in seconds
    var walkDuration: TimeInterval // in seconds
    var totalDuration: TimeInterval // in seconds
    var isTotalRunningTime: Bool
    var beepVolume: Float
    var numberOfBeeps: Int
}
