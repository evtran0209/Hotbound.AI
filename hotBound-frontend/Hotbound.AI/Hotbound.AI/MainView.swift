//
//  MainView.swift
//  Hotbound.AI
//
//  Created by Evelyn Tran on 10/19/24.
//

import SwiftUI

struct MainView: View {
    @State private var currentPage = 0
    @State private var showingAccountSheet = false

    var body: some View {
        NavigationStack {
            VStack {
                switch currentPage {
                case 0:
                    UploadView(currentPage: $currentPage)
                case 1:
                    ContextInputView(currentPage: $currentPage)
                case 2:
                    CallSimulationView(currentPage: $currentPage)
                default:
                    Text("Invalid page")
                }
                
                HStack {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentPage == index ? Color.black : Color.gray)
                            .frame(width: 10, height: 10)
                    }
                }
                .padding()
            }
            .navigationTitle("Sales Call Simulator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAccountSheet = true
                    }) {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAccountSheet) {
                AccountView()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
