//
//  PHASEAudioControler.swift
//  PHASEShowcase
//
//  Created by Adam Czyżak on 09/01/2025.
//
import PHASE

class PHASEAudioController: ObservableObject{
    private var soundSourcePosition: simd_float4x4 = matrix_identity_float4x4
    private var audioAsset: PHASESoundAsset!
    private let phaseEngine: PHASEEngine
    private let params = PHASEMixerParameters()
    private let soundSource: PHASESource
    private var phaseListener:  PHASEListener!
    private var soundEventAsset: PHASESoundEventNodeAsset?
    private let soundPipeline = PHASESpatialMixerDefinition(
        spatialPipeline: PHASESpatialPipeline(
            flags: .directPathTransmission)!
    )

    init() {
        // Init PHASE Engine
        phaseEngine = PHASEEngine(updateMode: .automatic)
        phaseEngine.defaultReverbPreset = .cathedral
        
        // Set listener position to (0,0,0) in World space
        let origin: simd_float4x4 = matrix_identity_float4x4
        phaseListener = PHASEListener(engine: phaseEngine)
        phaseListener.transform = origin
        try! self.phaseEngine.rootObject.addChild(self.phaseListener)
        do{
            try self.phaseEngine.start();
        }
        catch {
            print("Could not start PHASE engine")
        }
        
        // Load sound to play (AudioAsset)
        let data = PHASEAudioController.generateSineWave(frequency: 441.0, duration:  20.0)
        let audioData = PHASEAudioController.convertBufferToData(buffer: data)
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)!
        do {
            audioAsset = try phaseEngine.assetRegistry.registerSoundAsset(data: audioData,
                                                                          identifier: "sine_wave_sound",
                                                                          format: audioFormat,
                                                                          normalizationMode: .dynamic)
        } catch {
            print("Failed to register the sound asset: \(error.localizedDescription)")
        }
        
        // Create sound Source
        soundSource = PHASESource(engine: phaseEngine)
        soundSourcePosition.translate(z:5.0)
        soundSource.transform = soundSourcePosition
        print(soundSourcePosition)
        do {
            try phaseEngine.rootObject.addChild(soundSource)
        }
        catch {
            print ("Failed to add a child object to the scene.")
        }
        
        // Prepare model
        let simpleModel = PHASEGeometricSpreadingDistanceModelParameters()
        simpleModel.rolloffFactor = 1.0
        soundPipeline.distanceModelParameters = simpleModel
        
        let samplerNode = PHASESamplerNodeDefinition(
            soundAssetIdentifier: audioAsset.identifier,
            mixerDefinition: soundPipeline,
            identifier: audioAsset.identifier + "_SamplerNode")
        samplerNode.playbackMode = .looping
 
        // Create event asset
        do {soundEventAsset = try
            phaseEngine.assetRegistry.registerSoundEventAsset(
            rootNode: samplerNode,
            identifier: audioAsset.identifier + "_SoundEventAsset")
        } catch {
            print("Failed to register a sound event asset.")
            soundEventAsset = nil
        }
    }
    
    
    func updateAudioPlayerPositon(x: Float = 0, y: Float = 0, z: Float = 0){
        soundSourcePosition.setPosition(x:x, y:y, z:z)
        soundSource.transform = soundSourcePosition
    }
    
    func playSound(){
        guard let soundEventAsset else { return }
        
        params.addSpatialMixerParameters(
            identifier: soundPipeline.identifier,
            source: soundSource,
            listener: phaseListener)
        let soundEvent = try! PHASESoundEvent(engine: phaseEngine,
                                              assetIdentifier: soundEventAsset.identifier,
                                              mixerParameters: params)
        soundEvent.start(completion: nil)
    }
    
    static func generateSineWave(frequency: Float, duration: Float, sampleRate: Float = 44100.0) -> AVAudioPCMBuffer {
        let totalSamples = Int(sampleRate * duration)
        let amplitude: Float = 0.5

        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(totalSamples))!
        buffer.frameLength = AVAudioFrameCount(totalSamples)
        let samples = buffer.floatChannelData![0]
        let angularFrequency = 2.0 * Float.pi * frequency / sampleRate
        for i in 0..<totalSamples {
            samples[i] = amplitude * sin(angularFrequency * Float(i))
        }
        
        return buffer
    }
    
    static func convertBufferToData(buffer: AVAudioPCMBuffer) -> Data {
        guard let floatChannelData = buffer.floatChannelData else {
            fatalError("Buffer has no floatChannelData.")
        }
        let frameLength = Int(buffer.frameLength)
        var audioData = Data()
        
        for channel in 0..<Int(buffer.format.channelCount) {
            let channelData = floatChannelData[channel]
            let channelBytes = UnsafeBufferPointer(start: channelData, count: frameLength)
            audioData.append(contentsOf: UnsafeRawBufferPointer(channelBytes))
        }
        
        return audioData
    }

}
