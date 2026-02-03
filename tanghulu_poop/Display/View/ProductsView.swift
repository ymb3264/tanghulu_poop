//
//  ProductsView.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 11/29/25.
//

import SwiftUI
import Kingfisher
import UIKit

struct ProductsView: View {
    @Binding var selectedImageUrl: URL?
    @Binding var productNames: [String]
    
    @State private var products: [PoopProduct] = []
    @State private var userVotes: [UserProductVote] = []
    @State private var text: String = ""
    @State private var isSubmitBtnDisabled = true
    @State private var successMessageOpened: Bool = false
    
    @FocusState var focusState: Bool

    private let productService = PoopProductsService()
    
    var body: some View {
        let ranked = rankedProducts(products)
        
        VStack(spacing: 0) {
            Text("나한테는 이게 효과가 좋더라 🧃")
                .font(.system(size: 18))
                .padding(.vertical, 12)
                .padding(.horizontal, 26)
                .background(
                    RoundedRectangle(cornerRadius: 20).stroke(.moare, lineWidth: 2)
                )
            
            FitScrollView(maxHeight: 450) {
                ForEach(Array(ranked.enumerated()), id: \.element.product.productId) { index, item in
                    let rank = item.rank
                    let product = item.product
                    let productId = product.productId
                    let isVoted = userVotes.contains(where: { $0.productId == productId })
                    let fontSize: CGFloat = product.name.contains("니얼굴") ? 12 : 17
                    
                    HStack {
                        Text("\(rank)")
                            .frame(width: 30)
                        
                        Text(product.name)
                            .font(.system(size: fontSize))
                            .lineLimit(2)
                        
                        Spacer()
                        
                        if let imageUrl = product.imageUrl {
                            let url = URL(string: imageUrl)
                            
                            Button(action: {
                                selectedImageUrl = url
                            }) {
                                KFImage(url)
                                    .placeholder {
                                        ProgressView()
                                    }
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }
                        }
                        
                        Button(action: {
                            if isVoted {
                                Task {
                                    do {
                                        userVotes.removeAll { $0.productId == productId }
                                        updateLocalRecommendCount(productId: productId, delta: -1)
                                        
                                        try await productService.cancelVote(productId: productId)
                                    } catch {
                                        print("\(error)")
                                    }
                                }
                            } else {
                                Task {
                                    userVotes.append(UserProductVote(productId: productId))
                                    updateLocalRecommendCount(productId: productId, delta: 1)
                                    
                                    // 햅틱 효과
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    
                                    try await productService.addVote(date: Date(), productId: productId)
                                }
                            }
                        }) {
                            if isVoted {
                                Text("🔥")
                                    .frame(width: 26)
                            } else {
                                Image(systemName: "flame")
                                    .frame(width: 26)
                            }
                            
                            Text(" \(product.recommendCount)")
                                .frame(width: 24)
                        }
                        .foregroundStyle(.primary)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, index == ranked.count - 1 ? 10 : 0)
                }
            }
            
            Capsule()
                .fill(.moare)
                .frame(height: 1)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("제품을 추천해 보세요😊")
                Text("제품 이름을 적어 전송하면 관리자가 확인 후 리스트에 추가합니다.")
            }
            .font(.system(size: 15))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.secondary)
            .padding(.top, 8)
            
            ZStack {
                HStack {
                    VStack(spacing: 0) {
                        TextField(" 제품 이름 입력", text: $text)
                            .focused($focusState)
                            .submitLabel(.send)
                            .onSubmit {
                                submit()
                            }
                        
                        Capsule()
                            .fill(.moare)
                            .frame(height: 1)
                            .padding(.top, 6)
                    }
                    
                    Button(action: {
                        submit()
                    }) {
                        Text("전송")
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20).stroke(isSubmitBtnDisabled ? .gray : .moare, lineWidth: 1)
                            )
                    }
                    .foregroundStyle(isSubmitBtnDisabled ? .gray : .moare)
                    .disabled(isSubmitBtnDisabled)
                    .onChange(of: text) {
                        isSubmitBtnDisabled = text.isBlank
                    }
                }
                .frame(height: 40)
                
                if successMessageOpened {
                    Text("🎉 전송되었습니다 🎉")
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20).fill(.moare).opacity(0.7)
                        )
                        .offset(y: -40)
                }
            }
        }
        .onTapGesture {
            if focusState {
                focusState = false
            }
        }
        .onAppear {
            Task {
                do {
                    try await productService.loadProducts(completion: { products in
                        self.products = products
                        self.productNames = products.map { $0.name }
                    })
                    try await productService.loadUserVotes(completion: { votes in
                        userVotes = votes
                    })
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }
    
    private func rankedProducts(_ products: [PoopProduct]) -> [(rank: Int, product: PoopProduct)] {
        let sorted = products.sorted { $0.recommendCount > $1.recommendCount }

        var result: [(rank: Int, product: PoopProduct)] = []
        var lastCount: Int? = nil
        var lastRank: Int = 0

        for (index, product) in sorted.enumerated() {
            if product.recommendCount == lastCount {
                // 같은 추천수면 같은 rank
                result.append((lastRank, product))
            } else {
                // 다르면 현재 위치(index+1)가 rank
                let newRank = index + 1
                lastRank = newRank
                lastCount = product.recommendCount
                result.append((newRank, product))
            }
        }
        return result
    }
    
    private func updateLocalRecommendCount(productId: String, delta: Int) {
        guard let index = products.firstIndex(where: { $0.productId == productId }) else { return }
        products[index].recommendCount = max(0, products[index].recommendCount + delta)
    }
    
    private func submit() {
        Task {
            focusState = false
            try await Task.sleep(for: .seconds(0.1))
            try await productService.addProduct(date: Date(), productId: UUID().uuidString, name: text) {
                text = ""
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    successMessageOpened = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        successMessageOpened = false
                    }
                }
            }
        }
    }
}

struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct FitScrollView<Content: View>: View {
    let maxHeight: CGFloat
    @ViewBuilder var content: Content
    
    @State private var contentHeight: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            // maxHeight보다 contentHeight가 크면 .hidden()으로 해도 뒤에 공간을 차지해서 아예 그리지 않게함.
            if contentHeight <= maxHeight {
                // 1) 실제 높이 측정용 (ScrollView 밖)
                VStack(spacing: 0) {
                    content
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                contentHeight = proxy.size.height
                            }
                            .onChange(of: proxy.size) {
                                contentHeight = proxy.size.height
                            }
                    }
                )
                .hidden() // 화면엔 안 보이게
            }
            
            // 2) 실제 표시용 ScrollView
            ScrollView {
                VStack(spacing: 0) {
                    content
                }
            }
            .frame(height: min(contentHeight, maxHeight))
            .scrollDisabled(contentHeight <= maxHeight)
        }
    }
}

extension String {
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
