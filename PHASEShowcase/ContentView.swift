//
//  ContentView.swift
//  PHASEShowcase
//
//  Created by Adam Czyżak on 09/01/2025.
//

import SwiftUI
import PHASE

struct ContentView: View {
    @State private var x: Float = 0.0
    @State private var y: Float = 0.0
    @State private var z: Float = 3.0
    @State private var distance: Float = 5.0
    @State private var isEditing = false
    @State private var audio = 0
    @State private var radius: Float = 0.75
    @State private var distanceClosest: Float = 4.5
    @State private var insideOfSphere: Bool = false
    @State private var rolloffFactor: Double = 2.0
    @State private var selectedReverbPreset: PHASEReverbPreset = .mediumHall
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
                Button("Reset") {
                    x = 0
                    y = 0
                    z = 3
                    updatePosition()
                }.buttonStyle(.bordered)
                Button("Random") {
                    x = Float.random(in:-10..<10)
                    y = Float.random(in:-10..<10)
                    z = Float.random(in:-10..<10)
                    updatePosition()
                    // phaseAudioController.playSound()
                }.buttonStyle(.bordered)
                Button("(0,0,0) ") {
                    x = 0
                    y = 0
                    z = 0
                    updatePosition()
                }.buttonStyle(.bordered)
            }
            Text("Warning! Small objects when listener is inside them create VERY unpleasant sound, use (0,0,0) with caution.").foregroundStyle(Color.red).multilineTextAlignment(.center)

            //DEBUG TEXTS
            Spacer()
            Text("Distance from center \(String(format: "%.2f",distance))m")
            Text("Distance from closest point in sphere \(String(format: "%.2f",distanceClosest))m")
            if insideOfSphere {
                Text("Listener inside of sphere").foregroundStyle(Color.red)
            }else {
                Text("\t")
            }

            
            // SLIDER SPHERE RADIUS
            Spacer()
            Text("Sphere Radius \(String(format: "%.2f",radius))m")
            Slider(value: $radius,
                   in: 0.1...10.1,
                   step: 0.1){
                Text("Axis length")
            } minimumValueLabel: {
                Text("0.1m")
            } maximumValueLabel: {
                Text("10.0m")
            } onEditingChanged: { editing in
                if !editing {
                    print("Finished editing Sphere radius: \(radius)")
                    //phaseAudioController.switchSoundSphereObject(radius)
                }
            }
            Spacer()
//       
//            Text("Rolloff factor \(String(format: "%.2f",radius))m")
//            Slider(value: $rolloffFactor,
//                   in: 0.1...10.1,
//                   step: 0.1){
//                Text("rolloffFactor")
//            } minimumValueLabel: {
//                Text("0.1")
//            } maximumValueLabel: {
//                Text("10.0")
//            } onEditingChanged: { editing in
//                if !editing {
//                    print("Finished editing rolloffFactor: \(rolloffFactor)")
//                    phaseAudioController.editModel(rolloffFactor)
//                }
//            }
//            Spacer()
//            B
            Text("Select Reverb Preset") .font(.subheadline)
                        
            Picker("Reverb Preset", selection: $selectedReverbPreset) {
                ForEach(PHASEReverbPreset.allCases, id: \.self) { preset in
                    Text(preset.displayName).tag(preset)
                }
            }
            .pickerStyle(MenuPickerStyle()) // Dropdown menu
            .onChange(of: selectedReverbPreset) { _, newValue in
               phaseAudioController.switchReverbProfile(newValue)
            }
            
            Text("Not fully implemneted yet")
        }.onAppear(){
            phaseAudioController.playSound()
            distanceClosest = distance - radius
                phaseAudioController.switchSoundSphereObject(radius)
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
