//
//  AVEnvirmentAudioController.swift
//  PHASEShowcase
//
//  Created by Adam Czyżak on 14/01/2025.
//

import AVFoundation
import ARKit

class AVEnvironmentAudioController: ObservableObject {
    private var audioEngine: AVAudioEngine
    private var environmentNode: AVAudioEnvironmentNode
    private var audioPlayerNode: AVAudioPlayerNode
    private var audioFile: AVAudioFile?
    private var soundSourcePosition: AVAudio3DPoint = AVAudio3DPoint(x: 200.0, y: 0.0, z: 2.0)
    private let rolloffFactor: Float = 2.0
    private let frequency: Float = 440.0

    init() {
        var defaultConfiguration: ARWorldTrackingConfiguration {
          let configuration = ARWorldTrackingConfiguration()
          configuration.planeDetection = .horizontal
          configuration.worldAlignment = .gravityAndHeading
          configuration.isAutoFocusEnabled = true
          return configuration
        }
        
        audioEngine = AVAudioEngine()
        environmentNode = AVAudioEnvironmentNode()
        audioPlayerNode = AVAudioPlayerNode()

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("Failed to configure AVAudioSession: \(error.localizedDescription)")
        }

        setupEnvironment()
        loadAudioFile()
        configureAudioEngine()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        audioEngine.stop()
    }

    private func setupEnvironment() {
        environmentNode.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environmentNode.listenerAngularOrientation = AVAudio3DAngularOrientation(yaw: 0, pitch: 0, roll: 0)
        environmentNode.distanceAttenuationParameters.rolloffFactor = rolloffFactor
        environmentNode.distanceAttenuationParameters.referenceDistance = 1.0
    }

    private func loadAudioFile() {
        // Generate sine wave data or load an audio file
        let sineWaveData = AVEnvironmentAudioController.generateSineWave(frequency: frequency, duration: 1.0)
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)!
        audioFile = AVEnvironmentAudioController.createAudioFile(from: sineWaveData, format: audioFormat)
    }

    private func configureAudioEngine() {
        let audioSession = AVAudioSession.sharedInstance()
         let outputDataSource = audioSession.outputDataSource
         debugPrint("Audio Output DataSource: \(String(describing: outputDataSource?.dataSourceName))")
         // If bluetooth headsets are connected, select a better rendering algorithm
         if outputDataSource?.dataSourceName == "Built-in Output: Headphones" ||
                outputDataSource?.dataSourceName == "Built-in Output: AirPods" {
                 if outputDataSource?.dataSourceName == "Built-in Output: AirPods" {
                     environmentNode.renderingAlgorithm = .sphericalHead
                 }
                 else {
                     // HRTFHQ for the rest of headphones
                     environmentNode.renderingAlgorithm = .HRTFHQ
                 }
         } else {
             // No Bluetooth headset is connected: use the default rendering algorithm
             environmentNode.renderingAlgorithm = .equalPowerPanning
         }
        audioEngine.attach(environmentNode)
        audioEngine.attach(audioPlayerNode)
        environmentNode.renderingAlgorithm = .HRTFHQ

        audioEngine.connect(environmentNode, to: audioEngine.mainMixerNode, format: nil)
        audioEngine.connect(audioPlayerNode, to: environmentNode, format: nil)
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start AVAudioEngine: \(error.localizedDescription)")
        }
    }

    @objc private func handleInterruption(notification: Notification) {
        if let userInfo = notification.userInfo,
           let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
           let type = AVAudioSession.InterruptionType(rawValue: typeValue) {
            switch type {
            case .began:
                audioEngine.pause()
            case .ended:
                audioEngine.prepare()
                do {
                    try audioEngine.start()
                } catch {
                    print("Failed to resume AVAudioEngine: \(error.localizedDescription)")
                }
            default:
                break
            }
        }
    }

    func updateSoundSourcePosition(x: Float, y: Float, z: Float) {
        soundSourcePosition = AVAudio3DPoint(x: x,y: y,z:  z)
        audioPlayerNode.position = soundSourcePosition
    }

    func playSound() {
        guard let audioFile = audioFile else { return }
        audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: {        self.playSound()})
        audioPlayerNode.position = soundSourcePosition
        audioPlayerNode.reverbBlend = 0.5
        audioPlayerNode.volume = 1.0
        audioPlayerNode.play()
    }

    func stopSound() {
        audioPlayerNode.stop()
    }

    // Utility Functions
    static func generateSineWave(frequency: Float, duration: Double) -> AVAudioPCMBuffer {
        let sampleRate: Float = 44100.0
        let frameCount = Int(sampleRate * Float(duration))
        let buffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)!, frameCapacity: AVAudioFrameCount(frameCount))!
        buffer.frameLength = AVAudioFrameCount(frameCount)
        let floatChannelData = buffer.floatChannelData![0]
        
        for frame in 0..<frameCount {
            floatChannelData[frame] = sin(2.0 * .pi * frequency * Float(frame) / sampleRate)
        }
        return buffer
    }

    static func createAudioFile(from buffer: AVAudioPCMBuffer, format: AVAudioFormat) -> AVAudioFile? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let audioURL = tempDirectory.appendingPathComponent("sineWave.caf")
        
        do {
            let audioFile = try AVAudioFile(forWriting: audioURL, settings: format.settings)
            try audioFile.write(from: buffer)
            return try AVAudioFile(forReading: audioURL)
        } catch {
            print("Failed to create audio file: \(error.localizedDescription)")
            return nil
        }
    }
}
