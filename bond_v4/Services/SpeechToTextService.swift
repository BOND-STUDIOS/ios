//
//  SpeechToTextService.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/8/25.
//

import Foundation
import Speech
import AVFoundation

@MainActor
class SpeechToTextService: ObservableObject {
    
    @Published private(set) var isRecording = false
    @Published private(set) var recognizedText = ""
    @Published private(set) var errorMessage: String?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    /// Requests user permission for microphone and speech recognition.
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if authStatus != .authorized || !granted {
                        self.errorMessage = "Speech recognition or microphone permission was denied."
                    }
                }
            }
        }
    }
    
    /// Starts transcribing audio from the microphone.
    func startTranscribing() {
        guard !isRecording else { return }
        
        // Ensure previous tasks are cancelled
        stopTranscribing()
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create recognition request") }
            recognitionRequest.shouldReportPartialResults = true
            
            let inputNode = audioEngine.inputNode
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    self.recognizedText = result.bestTranscription.formattedString
                } else if let error = error {
                    self.errorMessage = "Recognition task error: \(error.localizedDescription)"
                    self.stopTranscribing()
                }
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            self.recognizedText = ""
            self.isRecording = true
            
        } catch {
            self.errorMessage = "Error starting transcription: \(error.localizedDescription)"
            stopTranscribing()
        }
    }
    
    /// Stops transcribing audio.
    func stopTranscribing() {
        guard isRecording else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        
        self.recognitionRequest = nil
        self.recognitionTask = nil
        self.isRecording = false
    }
}
