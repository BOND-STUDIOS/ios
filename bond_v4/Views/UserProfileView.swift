//
//  UserProfileView.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/8/25.
//


import SwiftUI
import GoogleSignIn

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var agentAPI: AgentAPI
    @EnvironmentObject var audioPlayerService: AudioPlayerService
    @EnvironmentObject var speechToTextService: SpeechToTextService
    

    var body: some View {
        // Note: NavigationStack is the modern replacement for NavigationView
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [.black, .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // --- Top Aligned Content ---
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bond")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                Text("Connected")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer() // Pushes the VStack to the left
                    }
                    .padding(.horizontal)
                    .padding(.top, 50)
                    
                    // This Spacer pushes the header (above) to the top
                    // and the content (below) towards the bottom.
                    Spacer()
                    
                    // --- Center Aligned Content ---
                    Text(speechToTextService.recognizedText)
                        .font(.title2)
                        .frame(minHeight: 100)
                        .padding()
                    
                    Button {
                        toggleRecording()
                    } label: {
                        Image(systemName: speechToTextService.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(speechToTextService.isRecording ? .red : .accentColor)
                    }
                    
                    // --- Bottom Aligned Content ---
                    Button("Sign Out", action: authViewModel.disconnect)
                        .padding(.bottom, 30) // Add some padding from the bottom edge
                }
                .foregroundColor(.white) // Set default text color for the VStack
                .ignoresSafeArea()
                .onAppear {
                    speechToTextService.requestPermissions()
                }
            }
            .navigationBarHidden(true)
        }
    }
    private func toggleRecording() {
        if speechToTextService.isRecording {
            // Stop recording
            speechToTextService.stopTranscribing()
            
            // Create a task to send the result to your agent
            Task {
                let prompt = speechToTextService.recognizedText
                // Make sure the prompt isn't empty
                guard !prompt.isEmpty else { return }
                
                await agentAPI.sendPrompt(
                    prompt,
                    using: authViewModel,
                    audioPlayer: audioPlayerService,
                )
            }
        } else {
            // Start recording
            speechToTextService.startTranscribing()
        }
    }
}
