//////
//////  UserProfileView.swift
//////  bond_v4
//////
//////  Created by CJ Sanchez on 7/8/25.
//////
////
////
////import SwiftUI
////import GoogleSignIn
////
//struct UserProfileView: View {
//    @EnvironmentObject var authViewModel: AuthenticationViewModel
//    @EnvironmentObject var agentAPI: AgentAPI
//    @EnvironmentObject var audioPlayerService: AudioPlayerService
//    @EnvironmentObject var speechToTextService: SpeechToTextService
//    
//
//    var body: some View {
//        // Note: NavigationStack is the modern replacement for NavigationView
//        NavigationStack {
//            ZStack {
//                LinearGradient(
//                    colors: [.black, .black],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .ignoresSafeArea()
//                
//                VStack(spacing: 20) {
//                    // --- Top Aligned Content ---
//                    HStack {
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text("Bond")
//                                .font(.largeTitle)
//                                .fontWeight(.bold)
//                            
//                            HStack(spacing: 8) {
//                                Circle()
//                                    .fill(Color.green)
//                                    .frame(width: 8, height: 8)
//                                Text("Connected")
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                        Spacer() // Pushes the VStack to the left
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 50)
//                    
//                    // This Spacer pushes the header (above) to the top
//                    // and the content (below) towards the bottom.
//                    Spacer()
//                    
//                    // --- Center Aligned Content ---
//                    Text(speechToTextService.recognizedText)
//                        .font(.title2)
//                        .frame(minHeight: 100)
//                        .padding()
//                    
//                    Button {
//                        toggleRecording()
//                    } label: {
//                        Image(systemName: speechToTextService.isRecording ? "stop.circle.fill" : "mic.circle.fill")
//                            .font(.system(size: 60))
//                            .foregroundColor(speechToTextService.isRecording ? .red : .accentColor)
//                    }
//                    .disabled(agentAPI.isProcessing)
//                    
//                    // --- Bottom Aligned Content ---
//                    Button("Sign Out", action: authViewModel.signOut)
//                        .disabled(agentAPI.isProcessing)
//                        .padding(.bottom, 30) // Add some padding from the bottom edge
//                }
//                .foregroundColor(.white) // Set default text color for the VStack
//                .ignoresSafeArea()
//                .onAppear {
//                    speechToTextService.requestPermissions()
//                }
//            }
//            .navigationBarHidden(true)
//        }
//    }
//    private func toggleRecording() {
//        if speechToTextService.isRecording {
//            // Stop recording
//            speechToTextService.stopTranscribing()
//            
//            // Create a task to send the result to your agent
//            Task {
//                let prompt = speechToTextService.recognizedText
//                // Make sure the prompt isn't empty
//                guard !prompt.isEmpty else { return }
//                
//                await agentAPI.sendPrompt(prompt)
//            }
//        } else {
//            // Start recording
//            speechToTextService.startTranscribing()
//        }
//    }
//}
// In UserProfileView.swift

//import SwiftUI
//
//struct UserProfileView: View {
//    @EnvironmentObject var authViewModel: AuthenticationViewModel
//    @EnvironmentObject var agentAPI: AgentAPI
//    @EnvironmentObject var audioPlayerService: AudioPlayerService
//    @EnvironmentObject var speechToTextService: SpeechToTextService
//    
//    @State private var agentResponseText = ""
//    @State private var isAgentResponding = false
//    @State private var showingSidebar = false
//
//    
//    var body: some View {
//        NavigationStack{
//            ZStack {
//                LinearGradient(
//                    colors: [.black, .black],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .ignoresSafeArea()
//                VStack(spacing: 20) {
//                    HStack {
//                        VStack(alignment: .leading, spacing: 4) {
//                            HStack {
//                                Text("Bond")
//                                    .font(.largeTitle)
//                                    .fontWeight(.bold)
//                                    .foregroundColor(.white)
//                                Spacer()
//                                NavigationLink(destination: JournalView()) {
//                                    Image(systemName: "book.closed.fill")
//                                        .font(.title2)
//                                        .foregroundColor(.white)
//                                }
//                                Button("Sign Out", action: authViewModel.disconnect)
//                            }
//                            
//                            
//                            HStack(spacing: 8) {
//                                Circle()
//                                    .fill(Color.green)
//                                    .frame(width: 8, height: 8)
//                                Text("Connected")
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//                            }
//                            
//                        }
//                        Spacer()
//                        Button(action: {
//                            showingSidebar.toggle()
//                        }) {
//                            Image(systemName: "line.3.horizontal")
//                                .font(.title2)
//                                .foregroundColor(.white)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top)
//                    
//                    Spacer()
//                    
//                    ScrollView {
//                        if isAgentResponding || !agentResponseText.isEmpty {
//                            Text(agentResponseText)
//                                .font(.title2)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .foregroundColor(.white)
//                        } else {
//                            Text(speechToTextService.recognizedText)
//                                .font(.title2)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    .frame(minHeight: 100)
//                    .padding()
//                    
//                    Button {
//                        toggleRecording()
//                    } label: {
//                        Image(systemName: speechToTextService.isRecording ? "stop.circle.fill" : "mic.circle.fill")
//                            .font(.system(size: 60))
//                            .foregroundColor(isAgentResponding ? .gray : (speechToTextService.isRecording ? .red : .accentColor))
//                    }
//                    .disabled(isAgentResponding)
//                    
//                }
//                .padding()
//                .onAppear {
//                    speechToTextService.requestPermissions()
//                }
//            }
//        }
//        .navigationBarHidden(true)
//    }
//    
//    
//private func toggleRecording() {
//    if speechToTextService.isRecording {
//        speechToTextService.stopTranscribing()
//        Task {
//            let prompt = speechToTextService.recognizedText
//            guard !prompt.isEmpty else { return }
//            
//            self.agentResponseText = ""
//            self.isAgentResponding = true
//            audioPlayerService.stop()
//            
//            guard let idToken = authViewModel.idToken else {
//                agentAPI.errorMessage = "Not signed in."
//                isAgentResponding = false
//                return
//            }
//            
//            print("--- STARTING API CALL ---")
//            do {
//                let stream = agentAPI.streamPrompt(prompt, idToken: idToken)
//                print("✅ Stream connection opened...")
//                
//                for try await event in stream {
//                    print("✅ Received event: \(event.type)")
//                    switch event.type {
//                    case .text_chunk:
//                        if let content = event.content {
//                            agentResponseText += content
//                        }
//                    case .audio_chunk:
//                        if let audio = event.audioBase64 {
//                            print("   -> Queuing audio chunk...")
//                            audioPlayerService.addToQueue(base64String: audio)
//                        }
//                    default:
//                        break
//                    }
//                }
//                print("✅ Stream finished successfully.")
//                isAgentResponding = false
//                
//            } catch {
//                print("❌ Caught an error in the stream loop: \(error)")
//                agentAPI.errorMessage = error.localizedDescription
//                isAgentResponding = false
//            }
//        }
//    } else {
//        self.agentResponseText=""
//        speechToTextService.startTranscribing()
//    }
//}
//}
import SwiftUI

// This is the main view for the user's profile and agent interaction.
struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var agentAPI: AgentAPI
    @EnvironmentObject var audioPlayerService: AudioPlayerService
    @EnvironmentObject var speechToTextService: SpeechToTextService
    
    // State to control the sidebar's visibility
    @State private var isSidebarOpen = false
    @State private var agentResponseText = ""
    @State private var isAgentResponding = false
    
    var body: some View {
        // The NavigationStack is essential for the NavigationLink in the sidebar to work.
        NavigationStack {
            ZStack {
                // Main content view
                VStack(spacing: 20) {
                    // Header with menu button and title
                    HStack {
                        // Button to open the sidebar
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isSidebarOpen = true
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Centered Title
                        VStack(alignment: .center, spacing: 4) {
                            Text("Bond")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                        }
                        
                        Spacer()
                        
                        // A hidden button to keep the title perfectly centered
                        Image(systemName: "line.horizontal.3")
                            .font(.title2)
                            .foregroundColor(.white)
                            .opacity(0)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Spacer()
                    
                    // Agent response and text area
                    ScrollView {
                        if isAgentResponding || !agentResponseText.isEmpty {
                            Text(agentResponseText)
                                .font(.title2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)
                        } else {
                            Text(speechToTextService.recognizedText)
                                .font(.title2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(minHeight: 100)
                    .padding()
                    
                    // Microphone button
                    Button {
                        toggleRecording()
                    } label: {
                        Image(systemName: speechToTextService.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(isAgentResponding ? .gray : (speechToTextService.isRecording ? .red : .accentColor))
                    }
                    .disabled(isAgentResponding)
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [.black, .black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
                
                // --- Sidebar Implementation ---
                
                // Dimming overlay when sidebar is open
                if isSidebarOpen {
                    Color.black
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                isSidebarOpen = false
                            }
                        }
                }
                
                // The actual sidebar view, positioned off-screen by default
                SidebarView(isSidebarOpen: $isSidebarOpen)
                    .offset(x: isSidebarOpen ? 0 : -UIScreen.main.bounds.width)
            }
            .onAppear {
                speechToTextService.requestPermissions()
            }
            
        }
        .navigationBarHidden(true)
    }
    
    // This function remains unchanged.
    private func toggleRecording() {
        if speechToTextService.isRecording {
            speechToTextService.stopTranscribing()
            Task {
                let prompt = speechToTextService.recognizedText
                guard !prompt.isEmpty else { return }
                
                self.agentResponseText = ""
                self.isAgentResponding = true
                audioPlayerService.stop()
                
                guard let idToken = authViewModel.idToken else {
                    agentAPI.errorMessage = "Not signed in."
                    isAgentResponding = false
                    return
                }
                
                print("--- STARTING API CALL ---")
                do {
                    let stream = agentAPI.streamPrompt(prompt, idToken: idToken)
                    print("✅ Stream connection opened...")
                    
                    for try await event in stream {
                        print("✅ Received event: \(event.type)")
                        switch event.type {
                        case .text_chunk:
                            if let content = event.content {
                                agentResponseText += content
                            }
                        case .audio_chunk:
                            if let audio = event.audioBase64 {
                                print("   -> Queuing audio chunk...")
                                audioPlayerService.addToQueue(base64String: audio)
                            }
                        default:
                            break
                        }
                    }
                    print("✅ Stream finished successfully.")
                    isAgentResponding = false
                    
                } catch {
                    print("❌ Caught an error in the stream loop: \(error)")
                    agentAPI.errorMessage = error.localizedDescription
                    isAgentResponding = false
                }
            }
        } else {
            self.agentResponseText=""
            speechToTextService.startTranscribing()
        }
    }
}
