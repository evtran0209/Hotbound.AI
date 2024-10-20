//
//  APIService.swift
//  Hotbound.AI
//
//  Created by Evelyn Tran on 10/19/24.
//

import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "http://127.0.0.1:5000" // Update this with your backend URL when deployed
    
    private init() {}
    
    func analyzeProfile(images: [UIImage], completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/analyze_profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        for (index, image) in images.enumerated() {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"images\"; filename=\"image\(index).jpg\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(image.jpegData(compressionQuality: 0.8)!)
            body.append("\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        request.httpBody = body as Data
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let json = try JSONDecoder().decode([String: String].self, from: data)
                if let analysis = json["analysis"] {
                    completion(.success(analysis))
                } else {
                    completion(.failure(NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func transcribeAudio(audioData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/transcribe_audio")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"audio\"; filename=\"audio.wav\"\r\n")
        body.append("Content-Type: audio/wav\r\n\r\n")
        body.append(audioData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body as Data
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let json = try JSONDecoder().decode([String: String].self, from: data)
                if let transcript = json["transcript"] {
                    completion(.success(transcript))
                } else {
                    completion(.failure(NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func simulateConversation(userInput: String, conversationHistory: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/simulate_conversation")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "user_input": userInput,
            "conversation_history": conversationHistory
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let json = try JSONDecoder().decode([String: String].self, from: data)
                if let aiResponse = json["ai_response"] {
                    completion(.success(aiResponse))
                } else {
                    completion(.failure(NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

extension NSMutableData {
    func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
