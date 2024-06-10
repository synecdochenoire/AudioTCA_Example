//
//  Cover.swift
//  audiobook
//
//  Created by Pavlo Chornei  on 10.06.2024.
//

import SwiftUI
import ComposableArchitecture

struct Cover: View {
    var coverURL: String
    
    var body: some View {
       
        AsyncImage(url: URL(string: coverURL)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(0.7, contentMode: .fit)
                    .frame(alignment: .center)
                    .frame(maxWidth: 250)
                    .clipShape(.rect(cornerRadius: 15))
                    .padding()
            } else if phase.error != nil {
                ProgressView()
                Image(systemName: "questionmark.diamond")
                    .imageScale(.large)
            } else {
                ProgressView()
            }
        }
    }
}
