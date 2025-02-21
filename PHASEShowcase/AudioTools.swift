//
//  AudioTools.swift
//  PHASEShowcase
//
//  Created by Adam Czyżak on 21/02/2025.
//
import AVFoundation

 /**
      Creates sine wave and saves it to AVAudiouffer
  */
internal func generateSineWave(frequency: Float, duration: Float, sampleRate: Float = 44100.0) -> AVAudioPCMBuffer {
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
internal func convertBufferToData(buffer: AVAudioPCMBuffer) -> Data {
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
