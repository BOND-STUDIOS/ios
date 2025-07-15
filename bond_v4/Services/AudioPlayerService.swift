////
////  AudioService.swift
////  bond_v4
////
////  Created by CJ Sanchez on 7/8/25.
////
//
//// Create a new file: AudioPlayerService.swift
//
//import Foundation
//import AVFoundation
//
//@MainActor
//class AudioPlayerService: NSObject, ObservableObject, AVAudioPlayerDelegate {
//    
//    enum PlaybackState {
//        case stopped, playing, paused
//    }
//    
//    @Published private(set) var playbackState: PlaybackState = .stopped
//    
//    private var audioPlayer: AVAudioPlayer?
//    
//    /// Decodes a Base64 string and plays the resulting audio data.
//    /// - Parameter base64: The Base64 encoded audio string.
//    func play(base64: String) {
//        // Stop any currently playing audio
//        stop()
//        
//        // 1. Decode the Base64 string into Data
//        guard let audioData = Data(base64Encoded: base64) else {
//            print("Error: Could not decode Base64 string.")
//            return
//        }
//        
//        do {
//            // Configure the audio session to play sound
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)
//
//            // 2. Initialize the AVAudioPlayer with the data
//            audioPlayer = try AVAudioPlayer(data: audioData)
//            audioPlayer?.delegate = self // Set delegate to receive finish notifications
//            
//            // 3. Play the audio and update the state
//            audioPlayer?.play()
//            playbackState = .playing
//        } catch {
//            print("Error initializing or playing audio: \(error.localizedDescription)")
//        }
//    }
//    
//    func pause() {
//        guard let player = audioPlayer, player.isPlaying else { return }
//        player.pause()
//        playbackState = .paused
//    }
//    
//    func resume() {
//        guard let player = audioPlayer, !player.isPlaying else { return }
//        player.play()
//        playbackState = .playing
//    }
//    
//    func stop() {
//        audioPlayer?.stop()
//        audioPlayer = nil
//        playbackState = .stopped
//    }
//    
//    // MARK: - AVAudioPlayerDelegate
//    
//    // This delegate method is called when the audio finishes playing
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        playbackState = .stopped
//    }
//}
// In AudioPlayerService.swift

//import Foundation
//import AVFoundation
//
//@MainActor
//class AudioPlayerService: ObservableObject {
//    @Published private(set) var isPlaying = false
//    
//    private var player = AVQueuePlayer()
//    private var playerItemStatusObserver: NSKeyValueObservation?
//
//    /// Decodes a Base64 string, saves it to a temporary file, and adds it to the playback queue.
//    func addToQueue(base64String: String) {
//        guard let audioData = Data(base64Encoded: base64String) else {
//            print("Error: Could not decode Base64 string for audio queue.")
//            return
//        }
//        
//        do {
//            // Create a temporary file URL
//            let tempDir = FileManager.default.temporaryDirectory
//            let tempURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp3")
//            
//            // Write the audio data to the file
//            try audioData.write(to: tempURL)
//            
//            // Create a player item from the file and add it to the queue
//            let playerItem = AVPlayerItem(url: tempURL)
//            player.insert(playerItem, after: player.items().last)
//            
//            // If the player isn't already playing, start it.
//            if player.rate == 0 {
//                play()
//            }
//        } catch {
//            print("Error creating or adding audio file to queue: \(error)")
//        }
//    }
//    
//    func play() {
//        guard player.items().count > 0, !isPlaying else { return }
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)
//            player.play()
//            isPlaying = true
//        } catch {
//            print("Error starting playback: \(error)")
//        }
//    }
//    
//    func stop() {
//        player.removeAllItems()
//        player.pause()
//        isPlaying = false
//    }
//}

// In AudioPlayerService.swift

//import Foundation
//import AVFoundation
//
//@MainActor
//class AudioPlayerService: NSObject, ObservableObject {
//    @Published private(set) var isPlaying = false
//    
//    private var player = AVQueuePlayer()
//    
//    // ✅ 1. Add an array to hold references to the temporary file URLs
//    private var tempFileURLs: [URL] = []
//
//    func addToQueue(base64String: String) {
//        guard let audioData = Data(base64Encoded: base64String) else {
//            print("Error: Could not decode Base64 string for audio queue.")
//            return
//        }
//        
//        do {
//            let tempDir = FileManager.default.temporaryDirectory
//            let tempURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp3")
//            
//            try audioData.write(to: tempURL)
//            
//            // ✅ 2. Keep a reference to the new file URL
//            self.tempFileURLs.append(tempURL)
//            
//            let playerItem = AVPlayerItem(url: tempURL)
//            player.insert(playerItem, after: player.items().last)
//            
//            if player.rate == 0 {
//                play()
//            }
//        } catch {
//            print("Error adding audio to queue: \(error)")
//        }
//    }
//    
//    func play() {
//        guard player.items().count > 0, !isPlaying else { return }
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)
//            player.play()
//            isPlaying = true
//        } catch {
//            print("Error starting playback: \(error)")
//        }
//    }
//    
//    func stop() {
//        player.removeAllItems()
//        player.pause()
//        isPlaying = false
//        
//        // ✅ 3. Clean up all the temporary files that were created
//        for url in tempFileURLs {
//            try? FileManager.default.removeItem(at: url)
//        }
//        tempFileURLs.removeAll()
//    }
//}

import Foundation
import AVFoundation

@MainActor
class AudioPlayerService: NSObject, ObservableObject {
    @Published private(set) var isPlaying = false
    
    private var player = AVQueuePlayer()
    
    // ✅ 1. Add an array to hold references to the temporary file URLs
    private var inMemoryAssets: [MemoryAsset] = []

    func addToQueue(base64String: String) {
        guard let audioData = Data(base64Encoded: base64String) else {
            print("Error: Could not decode Base64 string for audio queue.")
            return
        }
        
        let assetHelper = MemoryAsset(data: audioData, fileType: .mp3)
        self.inMemoryAssets.append(assetHelper)
        
        
        let playerItem = AVPlayerItem(asset: assetHelper.makePlayerAsset())
        player.insert(playerItem, after: player.items().last)
        
        if player.rate == 0, player.error == nil {
            play()
        }
        
    }
    
    func play() {
        guard player.items().count > 0, !isPlaying else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player.play()
            isPlaying = true
        } catch {
            print("Error starting playback: \(error)")
        }
    }
    
    func stop() {
        player.removeAllItems()
        player.pause()
        isPlaying = false
        inMemoryAssets.removeAll()
    }
}
