//
//  Audiobook.swift
//  audiobook
//
//  Created by Pavlo Chornei  on 04.06.2024.
//

import Foundation
import ComposableArchitecture
import Combine
import SwiftUI
import AVFAudio
import AVFoundation

struct Audiobook: Reducer {
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.apiClient) var apiClient
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
                    
                case .startTapped:
                    guard let player = state.avPlayer else { return .none }
                    state.isPlaying = true
                    player.play()
                    return .run { send in
                        for await _ in clock.timer(interval: .seconds(1)) {
                            await send(.playbackTick)
                        }
                    }
                    .cancellable(id: TimerID(), cancelInFlight: true)
                    
                case .stopTapped:
                    guard let player = state.avPlayer else { return .none }
                    state.isPlaying = false
                    player.pause()
                    return .cancel(id: TimerID())
                    
                case .forwardTapped:
                    state.currentTime = min(state.currentTime + 10, state.duration)
                    let newTime = CMTime(seconds: state.currentTime, preferredTimescale: 1)
                    state.avPlayer?.seek(to: newTime)
                    return .none
                    
                case .rewindTapped:
                    state.currentTime = max(state.currentTime - 5, 0)
                    let newTime = CMTime(seconds: state.currentTime, preferredTimescale: 1)
                    state.avPlayer?.seek(to: newTime)
                    return .none
                    
                case .previousTapped:
                    state.keyPoint = max(state.keyPoint - 1, 1)
                    if let keyPointTime = timeInterval(for: state.keyPoint, in: state.book) {
                        state.currentTime = keyPointTime
                        let newTime = CMTime(seconds: keyPointTime, preferredTimescale: 1)
                        state.avPlayer?.seek(to: newTime)
                    }
                    return .none
                    
                case .nextTapped:
                    if state.keyPoint == 0 {
                        state.keyPoint += 1
                    } else {
                        state.keyPoint = min(state.keyPoint + 1, (state.book?.keyPoints.count ?? 1))
                    }
                    if let keyPointTime = timeInterval(for: state.keyPoint, in: state.book) {
                        state.currentTime = keyPointTime
                        let newTime = CMTime(seconds: keyPointTime, preferredTimescale: 1)
                        state.avPlayer?.seek(to: newTime)
                    }
                    return .none
                    
                case .sliderValueChanged(let newValue):
                    state.currentTime = newValue
                    let newTime = CMTime(seconds: newValue, preferredTimescale: 1)
                    state.avPlayer?.seek(to: newTime)
                    return .none
                    
                case .playbackTick:
                    guard state.isPlaying, let player = state.avPlayer else { return .none }
                    state.currentTime = player.currentTime().seconds
                    return .none
                    
                case .speedChangeTapped:
                    state.speed = state.speed > 1 ? 1 : 2
                    state.avPlayer?.rate = Float(state.speed)
                    return .none
                    
                    // Fetch Actions
                case .fetch:
                    state.isLoading = true
                    return .run { send in
                        do {
                            let book = try await apiClient.fetch()
                            await send(.fetchResponse(.success(book)))
                            guard let url = URL(string: book.audioUrl) else {
                                throw PlaybackError.failedToGetUrl
                            }
                            let playerItem = AVPlayerItem(url: url)
                            let player = AVPlayer(playerItem: playerItem)
                            await send(.audioInitialized(player))
                        } catch {
                            await send(.audioPlaybackError(.failedToPlay))
                        }
                    }
                    
                case .fetchResponse(let result):
                    state.isLoading = false
                    switch result {
                        case .success(let book):
                            state.book = book
                            state.duration = book.bookLenght
                        case .failure(let error):
                            state.errorMessage = error.localizedDescription
                    }
                    return .none
                    
                case .audioInitialized(let player):
                    state.avPlayer = player
                    state.errorMessage = nil
                    return .run { send in
                        let timeObserver = player.addPeriodicTimeObserver(
                            forInterval: CMTime(seconds: 1, preferredTimescale: 1),
                            queue: .main
                        ) { _ in
                            Task { await send(.playbackTick) }
                        }
                     
                        try Task.checkCancellation()
                        player.removeTimeObserver(timeObserver)
                    }
                    .cancellable(id: TimeObserverID())
                    
                case .audioPlaybackChanged(let isPlaying):
                    guard let player = state.avPlayer else { return .none }
                    if isPlaying {
                        player.play()
                    } else {
                        player.pause()
                    }
                    return .none
                    
                case .audioPlaybackError(let error):
                    state.errorMessage = "Failed to play audio: \(error.localizedDescription)"
                    state.isLoading = false
                    return .none
                case .binding(_):
                    return .none
                case .toggleSwitch:
                    state.audioToggled.toggle()
                    return .none
            }
        }
    }
    
    struct Environment {
        var apiClient: APIClient
    }
    
    enum Action: Equatable {
        case binding(BindingAction<State>)
        case startTapped
        case stopTapped
        case forwardTapped
        case rewindTapped
        case previousTapped
        case nextTapped
        case sliderValueChanged(Double)
        case playbackTick
        case speedChangeTapped
        case fetch
        case fetchResponse(Result<Book, BookFetchingError>)
        case audioInitialized(AVPlayer)
        case audioPlaybackChanged(Bool)
        case audioPlaybackError(PlaybackError)
        case toggleSwitch
    }
    
    struct State: Equatable {
        @Shared var avPlayer: AVPlayer?
        var isPlaying = false
        var keyPoint = 0
        var audioToggled = false
        var currentTime = 0.0
        var duration = 300.0
        var speed = 1
        var book: Book?
        var isLoading: Bool = false
        var errorMessage: String?
    }
    
    private func timeInterval(for keyPointIndex: Int, in book: Book?) -> TimeInterval? {
        guard let book = book, keyPointIndex < book.keyPoints.count else { return nil }
        let timeComponents = book.keyPoints[keyPointIndex].timestamp.split(separator: "-").map { String($0) }
        guard timeComponents.count == 2,
              let minutes = Double(timeComponents[0]),
              let seconds = Double(timeComponents[1]) else { return nil }
        return (minutes * 60) + seconds
    }
}

private struct TimerID: Hashable {}
private struct TimeObserverID: Hashable {}

extension AVAudioPlayer {
    var progress: Double {
        currentTime / duration
    }
}

enum PlaybackError: Error, Equatable {
    case failedToGetUrl
    case failedToPlay
}
