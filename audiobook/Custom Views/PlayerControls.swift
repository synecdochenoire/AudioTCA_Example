//
//  PlayerControls.swift
//  audiobook
//
//  Created by Pavlo Chornei  on 04.06.2024.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct PlayerControls: View {
    
    @EnvironmentObject var store: ViewStoreOf<Audiobook>
    
    var body: some View {
        HStack(spacing: 5) {
            Button(action: {
                store.send(.previousTapped)
            }
            ) {
                Image(systemName: "backward.end.fill")
                    .padding(10)
            }
            
            Button(action:{
                store.send(.rewindTapped)
            }
            ) {
                Image(systemName: "gobackward.5")
                    .padding(10)
            }
            
            Button(action: {
                store.send(store.isPlaying ? .stopTapped : .startTapped)   
            }, label: {
                Image(systemName: store.isPlaying ? "pause.fill" : "play.fill")
                    .frame(minHeight: 50)
                    .padding(10)
                    .font(.largeTitle)
                    .fontWeight(.black)
            })
            
            Button(action:{
                store.send(.forwardTapped)
            }
            ) {
                Image(systemName: "goforward.10")
                    .padding(10)
            }
            Button(action:{
                store.send(.nextTapped)
            }
            ) {
                Image(systemName: "forward.end.fill")
                    .padding(10)
            }
        }
        .foregroundStyle(.primary)
        .font(.title)
        .padding(.top)
    }
}
