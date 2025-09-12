//
//  Untitled.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 5/5/25.
//

import SwiftUI

struct MainView: View {
    @State private var isClicked = false
    @State private var isBtnVisible = true
    @State private var isSelectorVisible = false
    @State private var isWelcomeTextVisible = false
    @State private var isCheckTextVisible = false
    @State private var isCalendarVisisble = false
    @State private var isDirectCalendarClicked = false
    
    private let firstTextVisibleTime = 1.0
    private let textVisibleTime = 0.5
    private let aniDuration = 0.5
    private let firstDelayTime = 0.5
    
    @State var isSelected = false
    
    var body: some View {
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
                PoopSizeSelector(isSelected: $isSelected)
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
            
            if isCalendarVisisble {
                CalendarView()
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
                        isCalendarVisisble = true
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
                        isCalendarVisisble = true
                    }
                }
            }
        }
    }
}

#Preview {
    MainView()
}
