//
//  ContextInputView.swift
//  Hotbound.AI
//
//  Created by Evelyn Tran on 10/19/24.
//

import SwiftUI
import AVFoundation

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    private var audioRecorder: AVAudioRecorder?
    private var audioURL: URL?
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            audioURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("recording.m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioURL!, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }
    
    func getAudioData() -> Data? {
        guard let audioURL = audioURL else { return nil }
        return try? Data(contentsOf: audioURL)
    }
}

struct ContextInputView: View {
    @Binding var currentPage: Int
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var transcript = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            Text("Provide Additional Context")
                .font(.title)
                .padding()
            
            Button(action: {
                if audioRecorder.isRecording {
                    audioRecorder.stopRecording()
                    transcribeAudio()
                } else {
                    audioRecorder.startRecording()
                }
            }) {
                Image(systemName: audioRecorder.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(audioRecorder.isRecording ? .red : .blue)
            }
            .padding()
            
            Text("Transcript:")
                .font(.headline)
            
            ScrollView {
                Text(transcript)
                    .padding()
            }
            .frame(height: 200)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding()
            
            Button("Continue") {
                currentPage += 1
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(transcript.isEmpty)
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func transcribeAudio() {
        guard let audioData = audioRecorder.getAudioData() else {
            errorMessage = "Failed to get audio data"
            showError = true
            return
        }
        
        APIService.shared.transcribeAudio(audioData: audioData) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let transcription):
                    self.transcript = transcription
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
}
