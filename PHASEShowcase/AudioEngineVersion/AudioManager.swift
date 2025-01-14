//
//  AudioManager.swift
//  PHASEShowcase
//
//  Created by Adam Czyżak on 14/01/2025.
//

import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    private var audioEngine: AVAudioEngine!
    private var environmentNode: AVAudioEnvironmentNode!
    private var playerNode: AVAudioPlayerNode!
    private var audioFile: AVAudioFile?

    func setupAudio() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])

            try session.setActive(true)
        } catch {
            print("Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
        
        audioEngine = AVAudioEngine()
        environmentNode = AVAudioEnvironmentNode()
        playerNode = AVAudioPlayerNode()

        // Configure the environment node for spatial audio
        audioEngine.attach(environmentNode)
        audioEngine.attach(playerNode)

        // Connect nodes
        audioEngine.connect(playerNode, to: environmentNode, format: nil)
        audioEngine.connect(environmentNode, to: audioEngine.mainMixerNode, format: nil)

        // Enable spatial audio
        environmentNode.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environmentNode.listenerAngularOrientation = AVAudio3DAngularOrientation(yaw: 0, pitch: 0, roll: 0)
        environmentNode.distanceAttenuationParameters.referenceDistance = 1.0
        environmentNode.distanceAttenuationParameters.maximumDistance = 100.0
        environmentNode.distanceAttenuationParameters.rolloffFactor = 2.0 // Adjust for steeper or softer attenuation

        guard let audioURL = Bundle.main.url(forResource: "example", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }

        do {
            audioFile = try AVAudioFile(forReading: audioURL)
        } catch {
            print("Failed to load audio file: \(error)")
        }
    }

    func playSpatialAudio(pan: Float ) {
        guard let audioFile = audioFile else { return }

        // Set the player node position (e.g., left side)
        playerNode.position = AVAudio3DPoint(x: 10, y: 0, z: -10)

        // Schedule the audio file for playback
        playerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)

        do {
            try audioEngine.start()
            playerNode.play()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
}
