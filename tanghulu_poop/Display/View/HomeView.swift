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
        // TODO:
        // 추후 추가
        // - 며칠이상 똥 기록화면 사용자 똥 분석 기반 데이터 표시
        //  - ex) 30일 이상 기록 했을 시 요일별로 똥 쌀 확률 표시
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
