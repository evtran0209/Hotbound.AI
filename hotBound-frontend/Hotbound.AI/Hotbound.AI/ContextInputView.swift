//
//  ContextInputView.swift
//  Hotbound.AI
//
//  Created by Evelyn Tran on 10/19/24.
//

import SwiftUI

struct ContextInputView: View {
    @Binding var currentPage: Int
    @State private var isRecording = false
    @State private var transcript = ""
    
    var body: some View {
        VStack {
            Text("Building your prospect")
                .font(.title)
                .padding()
            
            Text("Tell me more...")
                .font(.headline)
            
            Button(action: {
                isRecording.toggle()
                // TODO: Implement Deepgram recording and transcription
            }) {
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(isRecording ? .red : .blue)
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
    }
}

struct ContextInputView_Previews: PreviewProvider {
    static var previews: some View {
        ContextInputView(currentPage: .constant(1))
    }
}
