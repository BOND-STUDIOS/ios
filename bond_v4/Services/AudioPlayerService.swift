//
//  AudioService.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/8/25.
//

// Create a new file: AudioPlayerService.swift

import Foundation
import AVFoundation

@MainActor
class AudioPlayerService: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    enum PlaybackState {
        case stopped, playing, paused
    }
    
    @Published private(set) var playbackState: PlaybackState = .stopped
    
    private var audioPlayer: AVAudioPlayer?
    
    /// Decodes a Base64 string and plays the resulting audio data.
    /// - Parameter base64: The Base64 encoded audio string.
    func play(base64: String) {
        // Stop any currently playing audio
        stop()
        
        // 1. Decode the Base64 string into Data
        guard let audioData = Data(base64Encoded: base64) else {
            print("Error: Could not decode Base64 string.")
            return
        }
        
        do {
            // Configure the audio session to play sound
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            // 2. Initialize the AVAudioPlayer with the data
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.delegate = self // Set delegate to receive finish notifications
            
            // 3. Play the audio and update the state
            audioPlayer?.play()
            playbackState = .playing
        } catch {
            print("Error initializing or playing audio: \(error.localizedDescription)")
        }
    }
    
    func pause() {
        guard let player = audioPlayer, player.isPlaying else { return }
        player.pause()
        playbackState = .paused
    }
    
    func resume() {
        guard let player = audioPlayer, !player.isPlaying else { return }
        player.play()
        playbackState = .playing
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        playbackState = .stopped
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    // This delegate method is called when the audio finishes playing
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playbackState = .stopped
    }
}
