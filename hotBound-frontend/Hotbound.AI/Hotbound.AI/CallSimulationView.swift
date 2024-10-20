//
//  CallSimulationView.swift
//  Hotbound.AI
//
//  Created by Evelyn Tran on 10/19/24.
//

import SwiftUI

struct CallSimulationView: View {
    @Binding var currentPage: Int
    @State private var isCallActive = false
    @State private var showingPersonaNotes = false
    @State private var aiResponse = ""
    @State private var userInput = ""
    @State private var conversationHistory: [Message] = []
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            if isCallActive {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            isCallActive = false
                            currentPage = 0
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    
                    ScrollView {
                        LazyVStack {
                            ForEach(conversationHistory, id: \.id) { message in
                                MessageBubble(message: message)
                            }
                        }
                    }
                    
                    HStack {
                        TextField("Type your message...", text: $userInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: sendMessage) {
                            Image(systemName: "paperplane.fill")
                        }
                    }
                    .padding()
                    
                    Button("Show Persona Notes") {
                        showingPersonaNotes = true
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .sheet(isPresented: $showingPersonaNotes) {
                    PersonaNotesView()
                }
            } else {
                Text("Press to start call")
                    .font(.title)
                    .padding()
                
                Button(action: {
                    isCallActive = true
                }) {
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.green)
                }
            }
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func sendMessage() {
        guard !userInput.isEmpty else { return }
        
        let userMessage = Message(content: userInput, isUser: true)
        conversationHistory.append(userMessage)
        
        let history = conversationHistory.map { $0.content }.joined(separator: "\n")
        
        APIService.shared.simulateConversation(userInput: userInput, conversationHistory: history) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let aiResponse):
                    let aiMessage = Message(content: aiResponse, isUser: false)
                    self.conversationHistory.append(aiMessage)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
                self.userInput = ""
            }
        }
    }
}

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            Text(message.content)
                .padding()
                .background(message.isUser ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            if !message.isUser { Spacer() }
        }
        .padding(.horizontal)
    }
}

struct PersonaNotesView: View {
    var body: some View {
        VStack {
            Text("Prospect Persona Notes:")
                .font(.title)
                .padding()
            
            // TODO: Implement dynamic persona notes
            Text("Persona details will appear here")
                .padding()
        }
    }
}

struct CallSimulationView_Previews: PreviewProvider {
    static var previews: some View {
        CallSimulationView(currentPage: .constant(2))
    }
}
