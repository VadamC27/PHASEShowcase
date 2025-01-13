//
//  ContentView.swift
//  PHASEShowcase
//
//  Created by Adam Czyżak on 09/01/2025.
//

import SwiftUI
import PHASE
import RealityKit

struct ContentView: View {
    @State private var x: Float = 0.0
    @State private var y: Float = 0.0
    @State private var z: Float = 3.0
    @State private var distance: Float = 5.0
    @State private var isEditing = false
    @State private var audio = 0
    @State private var radius: Float = 0.5
    @State private var distanceClosest: Float = 4.5
    @State private var insideOfSphere: Bool = false
    @EnvironmentObject private var phaseAudioController: PHASEAudioController

    var body: some View {
        VStack {
            // HEADER
            Spacer()
            Image(systemName: "cube")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Spacer()
            Text("X: \(String(format: "%.2f", x))\tY: \(String(format: "%.2f", y))\tZ: \(String(format: "%.2f", z))").bold().font(.title3)
            Text("X Position")
            
            // SLIDERS X Y Z
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
                updatePosition()
            }
            Text("Y Position")
            
            Slider(value: $y,
                   in: -10.0...10.0,
                   step: 0.05){
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
                   step: 0.05){
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
            HStack{
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
            }

            //DEBUG TEXTS
            Spacer()
            Text("Distance from center \(String(format: "%.2f",distance))m")
            Text("Distance from closest point in sphere \(String(format: "%.2f",distanceClosest))m")
            if insideOfSphere {
                Text("Listener inside of sphere").foregroundStyle(Color.red)
            }
            Text("Sphere Radius \(String(format: "%.2f",radius))m")
            
            // SLIDER SPHERE RADIUS
            Spacer()
            Text("Sphere Radius")
            Slider(value: $radius,
                   in: 0.1...10.0,
                   step: 0.1){
                Text("Axis length")
            } minimumValueLabel: {
                Text("0.1m")
            } maximumValueLabel: {
                Text("10.0m")
            } onEditingChanged: { editing in
                if !editing {
                    print("Finished editing Sphere radius: \(radius)")
                    phaseAudioController.switchSoundSphereObject(radius)
                }
            }
            Spacer()
            
        }.onAppear(){
            phaseAudioController.playSound()
            distanceClosest = distance - radius
        }
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
        .onChange(of:radius){
            updatePosition()
        }

    }
    
    func updatePosition(){
        phaseAudioController.updateAudioPlayerPositon(x:x, y:y, z:z)
        calculateDistance()
    }
    
    func calculateDistance(){
        distance = pow(x*x + y*y + z*z,1/2)
        distanceClosest = distance - radius
        if distanceClosest < 0{
            insideOfSphere = true
        } else {
            insideOfSphere = false
        }
    }
}

//#Preview {
//    ContentView()
//}
