//
//  audiobookApp.swift
//  audiobook
//
//  Created by Pavlo Chornei  on 28.05.2024.
//

import SwiftUI
import ComposableArchitecture
import AVFoundation

@main
struct audiobookApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(
                initialState: Audiobook.State(avPlayer: Shared.init(
                    wrappedValue: AVPlayer(),
                    .inMemory("audio"))),
                reducer: { Audiobook() })
            )
        }
    }
}
