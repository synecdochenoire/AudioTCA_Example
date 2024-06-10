//
//  ContentView.swift
//  audiobook
//
//  Created by Pavlo Chornei  on 28.05.2024.
//

import SwiftUI
import ComposableArchitecture
import AVFAudio
import AVFoundation

struct ContentView: View {
    
    let store: StoreOf<Audiobook>
    
    var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
                ZStack {
                    ColorPalette.appLightBG
                        .ignoresSafeArea()
                    
                    VStack {
                        Cover(coverURL: viewStore.book?.coverUrl ?? Constants.placeholderImageURL)
                        
                        KeyPointsCounter(numberOfPoint: viewStore.state.book?.keyPoints.count, currentPoint: viewStore.state.keyPoint)
                        
                        keyPointLabel(for: viewStore)
                        
                        progressBar(for: viewStore)
                        
                        speedButton(for: viewStore)
                        
                        PlayerControls()
                            .environmentObject(viewStore)
                        
                        AudioToggle(audioToggleState: viewStore.audioToggled) {
                            viewStore.send(.toggleSwitch, animation: .spring(.bouncy, blendDuration: 0.5))
                        }
                    }
                    .padding()
                }
                .task {
                    viewStore.send(.fetch)
                }
        }
    }
    
    @ViewBuilder private func speedButton(for store: ViewStoreOf<Audiobook>) -> some View {
        Button("Speed x\(store.speed)") {
            store.send(.speedChangeTapped)
        }
        .frame(height: 25)
        .padding()
        .buttonStyle(GrowingButton())
    }

    
    @ViewBuilder private func keyPointLabel(for viewStore: ViewStoreOf<Audiobook>) -> some View {
        if let book = viewStore.book, viewStore.keyPoint < book.keyPoints.count + 1 && viewStore.keyPoint != 0{
            Text(book.keyPoints[viewStore.keyPoint - 1].title)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .padding(.top, 5)
        } else if viewStore.keyPoint == 0 {
            if let time = timeInterval(for: 0, in: viewStore.state.book) {
                Text("Next key point at \(timeString(time: time))")
                    .padding(.top, 5)
            }
        } else {
            Text("No Key Point")
                .padding(.top, 5)
        }
    }
    
    @ViewBuilder private func progressBar(for viewStore: ViewStoreOf<Audiobook>) -> some View {
        HStack {
            Text(timeString(time: viewStore.currentTime))
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
            
            Slider(
                value: viewStore.binding(
                    get: \.currentTime,
                    send: { .sliderValueChanged($0) }),
                in: 0...viewStore.duration)
            .accentColor(.black)
            .animation(.smooth, value: viewStore.currentTime)
          
                          
            Text(timeString(time: viewStore.duration))
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
        .padding([.leading, .trailing], 10)
    }
    
    private func timeString(time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
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


#Preview {
    ContentView(store: Store(
        initialState: Audiobook.State(avPlayer: Shared.init(
            wrappedValue: AVPlayer(),
            .inMemory("audio"))),
        reducer: { Audiobook() })
    )
}
