//
//  ContentView.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 5/5/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedImageUrl: URL?
    
    @State private var productNames: [String] = []
    
    var body: some View {
        ScrollView {
            VStack {
                CalendarView(productNames: $productNames)
                ProductsView(selectedImageUrl: $selectedImageUrl, productNames: $productNames)
            }
            .padding()
        }
    }
}

//#Preview {
//    HomeView()
//}
