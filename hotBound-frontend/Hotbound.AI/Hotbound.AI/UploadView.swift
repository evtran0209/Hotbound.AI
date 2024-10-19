//
//  UploadView.swift
//  Hotbound.AI
//
//  Created by Evelyn Tran on 10/19/24.
//

import SwiftUI

struct UploadView: View {
    @Binding var currentPage: Int
    @State private var profileImages: [UIImage] = []
    @State private var isAnalyzing = false
    @State private var analysisResult = ""
    
    var body: some View {
        VStack {
            Text("What sales calls are we preparing for?")
                .font(.title)
                .padding()
            
            Text("Who is the prospect?")
                .font(.headline)
            
            Text("Upload their profile screenshots!")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(0..<4) { index in
                    if index < profileImages.count {
                        Image(uiImage: profileImages[index])
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(10)
                    } else {
                        Button(action: {
                            // TODO: Implement image picker
                        }) {
                            VStack {
                                Image(systemName: "arrow.up.circle")
                                    .font(.system(size: 40))
                                Text("Screenshot \(index + 1)")
                            }
                        }
                        .frame(height: 150)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
            
            Button("Analyze Profile") {
                analyzeProfile()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(profileImages.isEmpty || isAnalyzing)
            
            if isAnalyzing {
                ProgressView("Analyzing...")
            }
            
            if !analysisResult.isEmpty {
                Text("Analysis Result:")
                    .font(.headline)
                    .padding(.top)
                
                ScrollView {
                    Text(analysisResult)
                        .padding()
                }
                .frame(height: 200)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            Button("Continue") {
                currentPage += 1
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(analysisResult.isEmpty)
        }
    }
    
    private func analyzeProfile() {
        isAnalyzing = true
        // TODO: Implement profile analysis using Gemini 1.5 Pro
        // This will involve sending the images to your backend for processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            analysisResult = "Profile analysis result will appear here."
            isAnalyzing = false
        }
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView(currentPage: .constant(0))
    }
}
