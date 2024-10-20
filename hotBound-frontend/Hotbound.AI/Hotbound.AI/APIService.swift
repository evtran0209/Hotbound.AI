//
//  APIService.swift
//  Hotbound.AI
//
//  Created by Evelyn Tran on 10/19/24.
//

import Foundation
import Vapi

class APIService {
    static let shared = APIService()
    private var vapiClient: Vapi?

    private init() {
        // Initialize Vapi client with the API key from Info.plist
        if let apiKey = Bundle.main.infoDictionary?["VAPI_API_KEY"] as? String {
            vapiClient = Vapi(publicKey: apiKey)
        } else {
            print("Error: Vapi API key not found in Info.plist.")
        }

        // Set up Vapi event listeners
        setupVapiEventListeners()
    }

    // Set up event listeners for call and speech events
    private func setupVapiEventListeners() {
        guard let vapiClient = vapiClient else {
            print("Error: Vapi client not initialized.")
            return
        }

        // Listen for call start event
        vapiClient.on("callDidStart") {
            DispatchQueue.main.async {
                print("Call started")
                // Update UI to indicate call start (e.g., change button states)
            }
        }

        // Listen for call end event
        vapiClient.on("callDidEnd") {
            DispatchQueue.main.async {
                print("Call ended")
                // Update UI to indicate call end
            }
        }

        // Listen for speech start event
        vapiClient.on("speech-start") {
            DispatchQueue.main.async {
                print("Assistant is speaking")
                // Update UI to show that assistant is speaking
            }
        }

        // Listen for speech end event
        vapiClient.on("speech-end") {
            DispatchQueue.main.async {
                print("Assistant finished speaking")
                // Update UI to show that assistant has stopped speaking
            }
        }

        // Listen for message events (e.g., transcripts or function calls)
        vapiClient.on("appMessageReceived") { msg, _ in
            guard let message = msg as? [String: Any] else { return }

            if let type = message["type"] as? String {
                if type == "transcript" {
                    handleTranscriptMessage(message)
                } else if type == "function-call" {
                    handleFunctionCallMessage(message)
                }
            }
        }

        // Listen for error events
        vapiClient.on("error") { error in
            DispatchQueue.main.async {
                print("Error during call: \(error.localizedDescription)")
                // Handle error UI updates
            }
        }
    }

    // Handle transcript messages
    private func handleTranscriptMessage(_ message: [String: Any]) {
        if let transcriptType = message["transcriptType"] as? String,
           let text = message["text"] as? String {
            DispatchQueue.main.async {
                if transcriptType == "partial" {
                    print("Partial transcript: \(text)")
                    // Update UI with live partial transcript
                } else if transcriptType == "final" {
                    print("Final transcript: \(text)")
                    // Update UI with final transcript
                }
            }
        }
    }

    // Handle function call messages
    private func handleFunctionCallMessage(_ message: [String: Any]) {
        if let functionCall = message["functionCall"] as? [String: Any],
           let functionName = functionCall["name"] as? String {

            if functionName == "addTopping" {
                if let parameters = functionCall["parameters"] as? [String: Any],
                   let topping = parameters["topping"] as? String {
                    print("Add topping: \(topping)")
                    // Handle topping addition in the UI
                }
            } else if functionName == "goToCheckout" {
                print("Redirecting to checkout...")
                // Handle redirect to checkout in the UI
            }
        }
    }

    // Start a call using the assistant ID or assistant dictionary
    func startCall(assistantId: String, assistantOverrides: [String: Any] = [:]) {
        guard let vapiClient = vapiClient else {
            print("Error: Vapi client not initialized.")
            return
        }

        // Check if there's already an ongoing call
        if vapiClient.isCallActive {
            print("Error: There's already an ongoing call.")
            return
        }

        // Start the call with the assistant ID and optional overrides
        vapiClient.start(assistantId: assistantId, assistantOverrides: assistantOverrides) { result in
            switch result {
            case .success:
                print("Call started successfully")
            case .failure(let error):
                print("Error starting call: \(error.localizedDescription)")
            }
        }
    }

    // Stop the ongoing call
    func stopCall() {
        guard let vapiClient = vapiClient else {
            print("Error: Vapi client not initialized.")
            return
        }

        // Stop the ongoing call
        vapiClient.stop { result in
            switch result {
            case .success:
                print("Call stopped successfully")
            case .failure(let error):
                print("Error stopping call: \(error.localizedDescription)")
            }
        }
    }

    // Mute or unmute the call
    func setCallMuted(_ muted: Bool) {
        guard let vapiClient = vapiClient else {
            print("Error: Vapi client not initialized.")
            return
        }

        vapiClient.setMuted(muted)

        if muted {
            print("Call muted")
        } else {
            print("Call unmuted")
        }
    }
}
