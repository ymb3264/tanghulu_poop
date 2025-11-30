//
//  Untitled.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 5/5/25.
//

import SwiftUI
import Kingfisher

struct MainView: View {
    @State private var isClicked = false
    @State private var isBtnVisible = true
    @State private var isSelectorVisible = false
    @State private var isWelcomeTextVisible = false
    @State private var isCheckTextVisible = false
    @State private var isHomeVisisble = false
    @State private var isDirectCalendarClicked = false
    
    // 확대 이미지
    @State private var selectedImageUrl: URL? = nil
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    private let firstTextVisibleTime = 1.0
    private let textVisibleTime = 0.5
    private let aniDuration = 0.5
    private let firstDelayTime = 0.5
    
    @State var isSelected = false
    
    var body: some View {
        ZStack {
            VStack {
                if isBtnVisible {
                    Button(action: {
                        isClicked.toggle()
                    }) {
                        Text("나 똥싼다~~!!")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 26, weight: .semibold))
                            .padding(.vertical, 14)
                            .padding(.horizontal, 30)
                            .background(
                                isClicked ?
                                AnyView(RoundedRectangle(cornerRadius: 20).fill(Color.brown)) :
                                    AnyView(RoundedRectangle(cornerRadius: 20).stroke(Color.brown, lineWidth: 2))
                            )
                            .padding(.horizontal)
                    }
                    .foregroundStyle(isClicked ? .white : .brown)
                    
                    Button(action: {
                        isDirectCalendarClicked.toggle()
                    }) {
                        Text("똥 기록 확인하기")
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 8)
                            .padding(.horizontal, 6)
                            .opacity(0.9)
                            .overlay {
                                VStack {
                                    Spacer()
                                    Rectangle().fill(.green).frame(height: 2)
                                }
                                .opacity(0.7)
                            }
                    }
                    .foregroundStyle(.primary)
                    .padding(.top)
                }
                
                if isSelectorVisible {
                    PoopSizeSelectView(isSelected: $isSelected)
                }
                
                if isWelcomeTextVisible {
                    HStack {
                        Text("🎉 ")
                        Text("환상적입니다! 오늘도 성공적으로 똥을 쌌습니다!")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.purple)
                        Text(" 🎉")
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 20).stroke(Color.yellow, lineWidth: 2)
                    )
                    .padding(.horizontal, 8)
                }
                
                if isCheckTextVisible {
                    Text("나의 똥 기록을 확인해보세요 ✅")
                        .font(.system(size: 20))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 30)
                        .background(
                            RoundedRectangle(cornerRadius: 20).stroke(.green, lineWidth: 2)
                        )
                }
                
                if isHomeVisisble {
                    HomeView(selectedImageUrl: $selectedImageUrl)
                }
            }
            
            if let selectedImageUrl {
                GeometryReader { proxy in
                    let side = min(proxy.size.width, proxy.size.height) * 0.9
                    
                    ZStack {
                        Color.primary.opacity(0.7)
                               .ignoresSafeArea()
                               .onTapGesture {
                                   self.selectedImageUrl = nil
                               }
                        
                        KFImage(selectedImageUrl)
                            .placeholder { ProgressView() }
                            .resizable()
                            .scaledToFit()
                            .frame(width: side, height: side)
                            .scaleEffect(scale)
                            .gesture(magnificationGesture)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(alignment: .topLeading) {
                        Button {
                            self.selectedImageUrl = nil
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 24))
                                .foregroundStyle(.white)
                                .padding(.leading)
                        }
                    }
                }
            }
        }
        .onChange(of: isClicked) {
            if isClicked {
                DispatchQueue.main.asyncAfter(deadline: .now() + firstDelayTime) { // 0.5
                    withAnimation(.easeInOut(duration: aniDuration)) {
                        isBtnVisible = false
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + firstDelayTime + aniDuration) { // 1.0
                    withAnimation(.easeInOut(duration: aniDuration)) {
                        isSelectorVisible = true
                    }
                }
            }
        }
        .onChange(of: isSelected) {
            if isSelected {
                DispatchQueue.main.asyncAfter(deadline: .now() + firstDelayTime) { // 0.5
                    withAnimation(.easeInOut(duration: aniDuration)) {
                        isSelectorVisible = false
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + firstDelayTime + aniDuration) { // 1.0
                    withAnimation(.easeInOut(duration: aniDuration)) {
                        isWelcomeTextVisible = true
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + firstDelayTime + (aniDuration * 2) + firstTextVisibleTime) { // 2.0
                    withAnimation(.easeInOut(duration: aniDuration)) {
                        isWelcomeTextVisible = false
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + firstDelayTime + (aniDuration * 3) + firstTextVisibleTime) { // 2.5
                    withAnimation(.easeInOut(duration: aniDuration)) {
                        isCheckTextVisible = true
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + firstDelayTime + (aniDuration * 4) + (firstTextVisibleTime + textVisibleTime)) { // 3.5
                    withAnimation(.easeInOut(duration: aniDuration)) {
                        isHomeVisisble = true
                    }
                }
            }
        }
        .onChange(of: isDirectCalendarClicked) {
            if isDirectCalendarClicked {
                DispatchQueue.main.asyncAfter(deadline: .now() + firstDelayTime) { // 0.5
                    withAnimation(.easeInOut(duration: aniDuration)) {
                        isBtnVisible = false
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + firstDelayTime + aniDuration) { // 1.0
                    withAnimation(.easeInOut(duration: aniDuration)) {
                        isCheckTextVisible = true
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + firstDelayTime + (aniDuration * 2) + textVisibleTime) { // 2.0
                    withAnimation(.easeInOut(duration: aniDuration)) {
                        isHomeVisisble = true
                    }
                }
            }
        }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = lastScale * value
            }
            .onEnded { _ in
                // 최소/최대 배율 제한
                withAnimation(.spring()) {
                    scale = min(max(scale, 1.0), 4.0)
                    lastScale = scale
                }
            }
    }
}

#Preview {
    MainView()
}
