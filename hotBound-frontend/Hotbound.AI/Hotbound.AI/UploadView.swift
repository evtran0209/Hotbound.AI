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
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            Text("Upload LinkedIn Profile")
                .font(.title)
                .padding()
            
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
                            showImagePicker = true
                        }) {
                            VStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 40))
                                Text("Add Image")
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
        .sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImages.append(inputImage)
        self.inputImage = nil
    }
    
    private func analyzeProfile() {
        isAnalyzing = true
        APIService.shared.analyzeProfile(images: profileImages) { result in
            DispatchQueue.main.async {
                self.isAnalyzing = false
                switch result {
                case .success(let analysis):
                    self.analysisResult = analysis
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView(currentPage: .constant(0))
    }
}
