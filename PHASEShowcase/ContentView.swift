//
//  ContentView.swift
//  PHASEShowcase
//
//  Created by Adam Czyżak on 09/01/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var x: Float = 0.0
    @State private var y: Float = 0.0
    @State private var z: Float = 3.0
    @State private var distance: Float = 5.0
    @State private var isEditing = false
    @State private var audio = 0
    @EnvironmentObject private var phaseAudioController: PHASEAudioController
    var body: some View {
        VStack {
            
            
            Image(systemName: "cube")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("X: \(String(format: "%.2f", x))\tY: \(String(format: "%.2f", y))\tZ: \(String(format: "%.2f", z))").bold().font(.title3)
            Text("X Position")
            
            Slider(value: $x,
                   in: -10.0...10.0,
                   step: 0.1){
                Text("Speed")
            } minimumValueLabel: {
                Text("-10.0m")
            } maximumValueLabel: {
                Text("10.0m")
            } onEditingChanged: { editing in
                if !editing {
                    print("Finished editing X: \(x)")
                   
                }
                updatePosition()
            }
            Text("Y Position")
            
            Slider(value: $y,
                   in: -10.0...10.0,
                   step: 0.1){
                Text("Speed")
            } minimumValueLabel: {
                Text("-10.0m")
            } maximumValueLabel: {
                Text("10.0m")
            } onEditingChanged: { editing in
                if !editing {
                    print("Finished editing Y: \(y)")
              
                }
                updatePosition()
            }
            Text("Z Position")
            
            Slider(value: $z,
                   in: -10.0...20.0,
                   step: 0.1){
                Text("Speed")
            } minimumValueLabel: {
                Text("-10.0m")
            } maximumValueLabel: {
                Text("20.0m")
            } onEditingChanged: { editing in
                if !editing {
                    print("Finished editing Z: \(z)")
                  
                }
                updatePosition()
            }
            
            Button("Center") {
                x = 0
                y = 0
                z = 5
                updatePosition()
            }.buttonStyle(.bordered)
            Button("Random") {
                x = Float.random(in:-10..<10)
                y = Float.random(in:-10..<10)
                z = Float.random(in:-10..<10)
                updatePosition()
               // phaseAudioController.playSound()
            }.buttonStyle(.bordered)
            
//            Button("Change sample") {
//            } .buttonStyle(.borderedProminent).bold()
            
            Text("Distance \(distance)")
            
            
        }.onAppear(){
            phaseAudioController.playSound()}
        .padding()
        .onChange(of:x){
            updatePosition()
        }
        .onChange(of:y){
            updatePosition()
        }
        .onChange(of:z){
            updatePosition()
        }

    }
    
    func updatePosition(){
        phaseAudioController.updateAudioPlayerPositon(x:x, y:y, z:z)
        calculateDistance()
    }
    
    func calculateDistance(){
        distance = pow(x*x + y*y + z*z,1/2)
    }
}

#Preview {
    ContentView()
}
