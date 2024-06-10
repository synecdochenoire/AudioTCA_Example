//
//  AudioToggle.swift
//  audiobook
//
//  Created by Pavlo Chornei  on 10.06.2024.
//

import SwiftUI
import ComposableArchitecture

struct AudioToggle: View {
    
    let audioToggleState: Bool
    let task: EmptyClosure?
    
    var body: some View {
        ZStack {
            Capsule()
                .frame(width: 90, height: 44)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 35)
                        .stroke(.gray.opacity(0.2), lineWidth: 1)
                )
           
                ZStack{
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black)
                        .offset(x: audioToggleState ? 23 : -23)
                    
                    Image(systemName: "headphones")
                        .offset(x: -23)
                        .foregroundStyle(audioToggleState ? .black : .white)
                    
                    Image(systemName: "text.alignleft")
                        .foregroundStyle(audioToggleState ? .white : .black)
                        .fontWeight(.bold)
                        .offset(x: 23)
                }
                .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                .padding()
        }
        .onTapGesture {
            task?()
        }
        .padding()
    }
}

