//
//  TimerModel.swift
//  ReadySetBeep
//
//  Created by Marnick De Grave on 03/11/2024.
//

import Foundation
import AVFoundation
import Combine
import BackgroundTasks
import AudioToolbox
import UIKit

class TimerModel: ObservableObject {
    // MARK: - Published Properties
    @Published var timeRemaining: TimeInterval
    @Published var currentInterval: IntervalType
    @Published var isPaused: Bool = false
    @Published var intervalProgress: Double = 0.0

    // MARK: - Properties
    private var settings: IntervalSettings
    private var audioPlayer: AVQueuePlayer?
    private var intervalTimer: Timer?
    private var audioSessionConfigured: Bool = false

    private var totalElapsedTime: TimeInterval = 0
    private var completedIntervals: Int = 0
    private var totalIntervals: Int = 0
    private var intervalDuration: TimeInterval
    private var totalSessionDuration: TimeInterval = 0
    private var numberOfRunningIntervals: Int = 0
    private var numberOfWalkingIntervals: Int = 0

    // MARK: - Initializer
    init(settings: IntervalSettings) {
        self.settings = settings
        self.timeRemaining = settings.runDuration  // Initial value until properly set
        self.currentInterval = .run  // Assuming default value is 'run'
        self.intervalDuration = settings.runDuration  // Initialize with a default value to prevent uninitialized state

        // Configure initial values since the required properties are already set
        self.configureInitialValues(settings: settings)
        self.totalElapsedTime = 0
        self.completedIntervals = 0
        self.totalIntervals = 0
        
        // Configure the audio session
        configureAudioSession()
        
        // Register Background Tasks
        registerBackgroundTasks()
    }

    // MARK: - Configuration Methods
    private func configureInitialValues(settings: IntervalSettings) {
        let singleCycleDuration = settings.runDuration + settings.walkDuration

        guard singleCycleDuration > 0 else {
            fatalError("Run and Walk durations cannot both be zero.")
        }

        if settings.isTotalRunningTime {
            guard settings.runDuration > 0 else {
                fatalError("Run duration must be greater than zero.")
            }

            numberOfRunningIntervals = Int(ceil(settings.totalDuration / settings.runDuration))
            numberOfWalkingIntervals = numberOfRunningIntervals
            totalSessionDuration = Double(numberOfRunningIntervals) * (settings.runDuration + settings.walkDuration)
        } else {
            let numberOfFullCycles = Int(settings.totalDuration / singleCycleDuration)
            numberOfRunningIntervals = numberOfFullCycles
            numberOfWalkingIntervals = numberOfFullCycles

            let remainingTime = settings.totalDuration.truncatingRemainder(dividingBy: singleCycleDuration)
            if remainingTime >= settings.runDuration {
                numberOfRunningIntervals += 1
                if remainingTime - settings.runDuration >= settings.walkDuration {
                    numberOfWalkingIntervals += 1
                }
            } else if remainingTime > 0 {
                numberOfRunningIntervals += 1
            }

            totalSessionDuration = settings.totalDuration
        }

        totalIntervals = numberOfRunningIntervals + numberOfWalkingIntervals
    }

    private func configureAudioSession() {
        guard !audioSessionConfigured else { return }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowAirPlay])
            try audioSession.setActive(true)
            audioSessionConfigured = true
            print("Audio session configured successfully.")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    // MARK: - Timer Control Methods
    func start() -> Bool {
        guard totalIntervals > 0 else {
            print("Cannot start timer: total intervals is zero.")
            return false
        }
        print("Timer started.")
        startIntervalTimer()
        scheduleAppRefresh() // Schedule a background task for timer updates
        return true
    }

    func stop() {
        stopIntervalTimer()
        print("Timer stopped.")
    }

    func togglePause() {
        isPaused.toggle()
        if isPaused {
            stopIntervalTimer()
        } else {
            startIntervalTimer()
        }
    }

    private func startIntervalTimer() {
        stopIntervalTimer() // Invalidate any existing timer

        intervalTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(intervalTimer!, forMode: .common)
    }

    private func stopIntervalTimer() {
        intervalTimer?.invalidate()
        intervalTimer = nil
    }

    // MARK: - Timer Tick Logic
    private func tick() {
        guard !isPaused else { return }

        if timeRemaining > 0 {
            timeRemaining -= 1
            totalElapsedTime += 1
            updateProgress()
            checkForBeeps()

            if totalElapsedTime >= totalSessionDuration {
                stop()
            }
        } else {
            completedIntervals += 1
            if completedIntervals >= totalIntervals {
                stop()
            } else {
                switchInterval()
            }
        }
    }

    private func switchInterval() {
        if currentInterval == .run {
            currentInterval = .walk
            intervalDuration = settings.walkDuration
        } else {
            currentInterval = .run
            intervalDuration = settings.runDuration
        }
        timeRemaining = intervalDuration
        intervalProgress = 0.0
    }

    // MARK: - Progress and Beep Methods
    private func updateProgress() {
        intervalProgress = 1.0 - (timeRemaining / intervalDuration)
    }

    private func checkForBeeps() {
        if Int(timeRemaining) == settings.numberOfBeeps {
            scheduleBeeps()
        }
    }

    private func scheduleBeeps() {
        for i in 0..<settings.numberOfBeeps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                self.playBeep()
            }
        }
    }

    private func playBeep() {
        guard let soundURL = Bundle.main.url(forResource: "beep", withExtension: "mp3") else {
            print("Beep sound not found.")
            return
        }

        let playerItem = AVPlayerItem(url: soundURL)
        if audioPlayer == nil {
            audioPlayer = AVQueuePlayer(playerItem: playerItem)
        } else {
            audioPlayer?.replaceCurrentItem(with: playerItem)
        }

        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to activate audio session: \(error)")
        }

        audioPlayer?.play()
        print("Beep sound played.")
    }

    // MARK: - Background Task Handling
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "dev.protobear.ReadySetBeep.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }

    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "dev.protobear.ReadySetBeep.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Schedule after 15 minutes

        do {
            try BGTaskScheduler.shared.submit(request)
            print("App refresh scheduled successfully.")
        } catch {
            print("Failed to schedule app refresh: \(error)")
        }
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh() // Reschedule the next background refresh

        task.expirationHandler = {
            // Cleanup when the task is about to expire
            self.stopIntervalTimer()
            task.setTaskCompleted(success: false)
        }

        // Perform timer tick updates here
        if !isPaused {
            tick()
        }

        task.setTaskCompleted(success: true)
    }

    // MARK: - Computed Properties for UI
    var timeRemainingFormatted: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var totalElapsedTimeFormatted: String {
        let minutes = Int(totalElapsedTime) / 60
        let seconds = Int(totalElapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var totalTimeRemainingFormatted: String? {
        guard totalSessionDuration > totalElapsedTime else {
            return nil
        }
        let remaining = totalSessionDuration - totalElapsedTime
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var totalProgress: Double {
        return totalElapsedTime / totalSessionDuration
    }

    var currentSegment: Int {
        return completedIntervals + 1
    }

    var totalSegments: Int {
        return totalIntervals
    }
}
