//
//  TimerView.swift
//  ReadySetBeep
//
//  Created by Marnick De Grave on 03/11/2024.
//

import SwiftUI

struct TimerView: View {
    @StateObject private var timerModel: TimerModel
    @Environment(\.presentationMode) var presentationMode

    init(settings: IntervalSettings) {
        _timerModel = StateObject(wrappedValue: TimerModel(settings: settings))
    }

    var body: some View {
        ZStack {
            // Background Color Changes Based on Interval
            Color(timerModel.currentInterval == .run ? "RunColor" : "WalkColor")
                .ignoresSafeArea()

            VStack {
                // Top Timer Bar
                VStack {
                    // Time Labels
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Time Elapsed")
                                .font(.caption)
                                .foregroundColor(.white)
                            Text(timerModel.totalElapsedTimeFormatted)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Time Remaining")
                                .font(.caption)
                                .foregroundColor(.white)

                            // Ensure `totalTimeRemainingFormatted` is used properly
                            Text(timerModel.totalTimeRemainingFormatted ?? "00:00")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)

                    // Progress Bar
                    ProgressView(value: timerModel.totalProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .padding(.horizontal)
                }
                .padding(.top, 40)

                Spacer()

                // Circular Progress Indicator
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.3)
                        .foregroundColor(.white)

                    Circle()
                        .trim(from: 0.0, to: CGFloat(timerModel.intervalProgress))
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .foregroundColor(.white)
                        .rotationEffect(Angle(degrees: -90))

                    VStack {
                        Text(timerModel.timeRemainingFormatted)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)

                        Text(timerModel.currentInterval == .run ? "Running" : "Walking")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 250, height: 250)
                .padding()

                Spacer()

                // Segment Information
                Text("Segment \(timerModel.currentSegment) of \(timerModel.totalSegments)")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)

                // Control Buttons
                HStack(spacing: 40) {
                    Button(action: {
                        timerModel.togglePause()
                    }) {
                        Image(systemName: timerModel.isPaused ? "play.fill" : "pause.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                    }

                    Button(action: {
                        timerModel.stop()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 20)

                Spacer()
            }
        }
        .onAppear {
            print("TimerView appeared.")
            let started = timerModel.start()
            if !started {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
