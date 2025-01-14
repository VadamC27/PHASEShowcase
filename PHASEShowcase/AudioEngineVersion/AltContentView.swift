//
//  AltContentView.swift
//  PHASEShowcase
//
//  Created by Adam Czyżak on 14/01/2025.
//
import SwiftUI

struct AltContentView: View {
    @StateObject private var audioManager = AudioManager()
    @State var x: Float = 0
    var body: some View {
        VStack {
            Image(systemName: "headphones")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Spatial Audio Example")
            Button("Play Spatial Audio") {
                audioManager.playSpatialAudio(pan:x)
            }
            .padding()
            Text("X (Left/Right)")
            Slider(value: $x,
                   in: -10.0...10.0,
                   step: 0.05){
                Text("Speed")
            } minimumValueLabel: {
                Text("-10.0m")
            } maximumValueLabel: {
                Text("10.0m")
            } onEditingChanged: { editing in
                if !editing {
                    print("Finished editing X: \(x)")
                   
                }
               
            }
        }
        .padding()
        .onAppear {
            audioManager.setupAudio()
        }
    }
}
