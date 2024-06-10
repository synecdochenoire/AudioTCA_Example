//
//  GrowingButton.swift
//  audiobook
//
//  Created by Pavlo Chornei  on 04.06.2024.
//
import SwiftUI
import Foundation

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(.gray.opacity(0.1))
            .foregroundStyle(.primary)
            .clipShape(.rect(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .sensoryFeedback(.impact, trigger: configuration.isPressed)
            .font(.system(size: 15, weight: .bold))
    }
}
