//
//  AccountView.swift
//  Hotbound.AI
//
//  Created by Evelyn Tran on 10/19/24.
//

import SwiftUI

struct AccountView: View {
    @State private var name = "Jenny Jenkins"
    @State private var role = "High Ticket Sales Person"
    @State private var experienceLevel = "3-5 yrs"
    @State private var productSelling = "Enterprise Marketing Automation Tool"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    TextField("Role", text: $role)
                    TextField("Experience Level", text: $experienceLevel)
                }
                
                Section(header: Text("Product Information")) {
                    TextField("Product Selling", text: $productSelling)
                }
            }
            .navigationTitle("Account")
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}