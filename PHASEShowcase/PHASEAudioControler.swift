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
    private var soundSource: PHASESource
    private var phaseListener:  PHASEListener!
    private var soundEventAsset: PHASESoundEventNodeAsset?
    private let soundPipeline = PHASESpatialMixerDefinition(
        spatialPipeline: PHASESpatialPipeline(
            flags: [.directPathTransmission,  ])!
    )
    
    private let rolloffFactor = 2.0
    private let frequency: Float = 440.0
    
    init() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])

            try session.setActive(true)
        } catch {
            print("Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
        // Init PHASE Engine
        phaseEngine = PHASEEngine(updateMode: .automatic)
        phaseEngine.defaultReverbPreset = .largeHall
        phaseEngine.outputSpatializationMode = .alwaysUseChannelBased
        
        // Set listener position to (0,0,0) in World space
        let origin: simd_float4x4 = matrix_identity_float4x4
        phaseListener = PHASEListener(engine: phaseEngine)
        phaseListener.transform = origin
        phaseListener.automaticHeadTrackingFlags = .orientation
        try! self.phaseEngine.rootObject.addChild(self.phaseListener)
        do{
            try self.phaseEngine.start();
        }
        catch {
            print("Could not start PHASE engine")
        }
        

        let data = PHASEAudioController.generateSineWave(frequency: frequency, duration:  200.0)
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
        // Sphere promień 0.5
        soundSourcePosition.translate(z:3.0)
        let sphere = MDLMesh.newEllipsoid(withRadii: vector_float3(0.1,0.1,0.1), radialSegments: 14, verticalSegments: 14, geometryType: MDLGeometryType.triangles, inwardNormals: false, hemisphere: false, allocator: nil)
        let shape = PHASEShape(engine: phaseEngine, mesh: sphere)
        soundSource = PHASESource(engine: phaseEngine, shapes: [shape])
        soundSource.transform = soundSourcePosition
        print(soundSourcePosition)
        do {
            try phaseEngine.rootObject.addChild(soundSource) // Attach source to engine
        }
        catch {
            print ("Failed to add a child object to the scene.")
        }
        
        // Prepare model
        let simpleModel = PHASEGeometricSpreadingDistanceModelParameters()
        simpleModel.rolloffFactor = rolloffFactor
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

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /** Function needed for handling interuptions in sound playing - like turining off music or resuming AudioEngine work after notifcation*/
    @objc private func handleInterruption(notification: Notification) {
        if let userInfo = notification.userInfo,
           let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
           let type = AVAudioSession.InterruptionType(rawValue: typeValue) {
            switch type {
            case .began:
                break
            case .ended:
                if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume) {
                    }
                }
            default:
                break
            }
        }
    }
    
    /**
           Create new PHASESoundSource with spherical shape be setting axis length
     */
    func switchSoundSphereObject(_ axis: Float){
        phaseEngine.rootObject.removeChild(soundSource) // Remove previous object from engine
        
        //Create new SPHERE
        let sphere = MDLMesh.newEllipsoid(withRadii: vector_float3(axis,axis,axis), radialSegments: 14, verticalSegments: 14, geometryType: MDLGeometryType.triangles, inwardNormals: false, hemisphere: false, allocator: nil)
        let shape = PHASEShape(engine: phaseEngine, mesh: sphere)
        soundSource = PHASESource(engine: phaseEngine, shapes: [shape])
        
        soundSource.transform = soundSourcePosition
        print("Changing sphere")
        do {
            try phaseEngine.rootObject.addChild(soundSource)
        }
        catch {
        }
        
        playSound()
    }
    /**
            Updates sound source transformation with x,y,z position in 3D space
     */
    func updateAudioPlayerPositon(x: Float = 0, y: Float = 0, z: Float = 0){
        soundSourcePosition.setPosition(x:x, y:y, z:z)
        soundSource.transform = soundSourcePosition
    }
    /**
            Play sound in spatial space with currently set audio settings
     */
    func playSound(){
        // Fire new sound event with currently set properties
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
    /**
         Creates audio asset with sine wave
     */
    func setAudioAssetToSine(){
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
    }
    
    /**
         Creates audio asset with ready audio sample
     */
    func setAudioAssetToSample(){
        
        if let audioURL = Bundle.main.url(forResource: "eg_sound_short", withExtension: "mp3") {
          
            do {
                audioAsset = try phaseEngine.assetRegistry.registerSoundAsset(url: audioURL,
                                                                              identifier: "sine_wave_sound",
                                                                              assetType: .resident,
                                                                              channelLayout: nil,
                                                                              normalizationMode: .dynamic)
                print("Successfully registered sound asset: \(audioAsset.identifier)")
            } catch {
                print("Failed to register the sound asset: \(error.localizedDescription)")
            }
            
        } else {
            print("Audio file 'eg_sound_short.mp3' not found in the bundle.")
        }
    }
    
//    func editModel(_ rolloffFactor: Double){
//        let simpleModel = PHASEGeometricSpreadingDistanceModelParameters()
//        simpleModel.rolloffFactor = rolloffFactor
//        soundPipeline.distanceModelParameters = simpleModel
//        
//    }
    
    /**
         Creates sine wave and saves it to AVAudiouffer
     */
    private static func generateSineWave(frequency: Float, duration: Float, sampleRate: Float = 44100.0) -> AVAudioPCMBuffer {
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
    /**
         Transforms AVAudioBuffer to Data Type
     */
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
