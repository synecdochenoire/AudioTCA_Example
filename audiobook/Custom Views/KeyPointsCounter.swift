//
//  KeyPointsCounter.swift
//  audiobook
//
//  Created by Pavlo Chornei  on 10.06.2024.
//

import SwiftUI

struct KeyPointsCounter: View {
    
    let numberOfPoint: Int?
    let currentPoint: Int
    
    var body: some View {
        Text("Key Point \(currentPoint) of \(numberOfPoint ?? 0)")
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
    }
}
