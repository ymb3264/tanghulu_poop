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
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    // --
//    @State private var scale: CGFloat = 1.0
//    @State private var offset: CGSize = .zero
//
//    // 제스처 중 임시값
//    @GestureState private var gestureScale: CGFloat = 1.0
//    @GestureState private var gestureOffset: CGSize = .zero
//    @GestureState private var isPinching: Bool = false
    
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
                                   self.scale = 1.0
                                   self.offset = .zero
                               }
                        
                        KFImage(selectedImageUrl)
                            .placeholder { ProgressView() }
                            .resizable()
                            .scaledToFit()
                            .frame(width: side, height: side)
                            .scaleEffect(scale)
                            .offset(offset)
//                            .gesture(dragGesture.simultaneously(with: magnificationGesture))
                            .gesture(
                                dragGesture(side: side, containerSize: proxy.size)
                                    .simultaneously(with: magnificationGesture(side: side, containerSize: proxy.size))
                            )
                        
                        // --
//                            .scaleEffect(scale * gestureScale)
//                            .offset(x: offset.width + gestureOffset.width,
//                                    y: offset.height + gestureOffset.height)
//                            .gesture(instagramGesture)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(alignment: .topLeading) {
                        Button {
                            self.selectedImageUrl = nil
                            self.scale = 1.0
                            self.offset = .zero
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
    
//    private var instagramGesture: some Gesture {
//        let pinch = MagnificationGesture()
//            .updating($gestureScale) { value, state, _ in
//                state = value
//            }
//            .updating($isPinching) { _, state, _ in
//                state = true
//            }
//            .onEnded { _ in
//                // 핀치가 끝나면 무조건 원복(인스타 느낌)
//                resetWithAnimation()
//            }
//        
//        let drag = DragGesture()
//            .updating($gestureOffset) { value, state, _ in
//                state = value.translation
//            }
//            .onEnded { value in
//                // "확대된 상태"에서만 드래그 누적
//                let currentScale = scale * gestureScale
//                guard currentScale > 1.01 else { return }
//                
//                offset = CGSize(width: offset.width + value.translation.width,
//                                height: offset.height + value.translation.height)
//                
//                // 핀치가 아닌 “한손 이동”을 놓았을 때도 원복시키고 싶다면:
//                // (인스타는 보통 확대 유지가 아니라 원복이므로 여기서도 리셋)
//                resetWithAnimation()
//            }
//        
//        // 동시에 가능
//        return drag.simultaneously(with: pinch)
//    }
//    
//    private func resetWithAnimation() {
//        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
//            scale = 1.0
//            offset = .zero
//        }
//    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
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
    
    private func resetTransform() {
        withAnimation(.spring()) {
            scale = 1.0
            lastScale = 1.0
            offset = .zero
            lastOffset = .zero
        }
    }

    private func clamp(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, minValue), maxValue)
    }

    private func clampedOffset(_ proposed: CGSize, scale: CGFloat, side: CGFloat, containerSize: CGSize) -> CGSize {
        // 이미지 기본 크기(side x side)가 scale로 커진다고 가정
        let scaledW = side * scale
        let scaledH = side * scale

        // 이미지가 컨테이너보다 클 때만 이동 허용 범위가 생김
        let maxX = max(0, (scaledW - containerSize.width) / 2)
        let maxY = max(0, (scaledH - containerSize.height) / 2)

        return CGSize(
            width: clamp(proposed.width, min: -maxX, max: maxX),
            height: clamp(proposed.height, min: -maxY, max: maxY)
        )
    }

    private func dragGesture(side: CGFloat, containerSize: CGSize) -> some Gesture {
        DragGesture()
//            .onChanged { value in
//                // ✅ scale이 1보다 클 때만 이동 가능
//                guard scale > 1.0 else {
//                    offset = .zero
//                    lastOffset = .zero
//                    return
//                }
//
//                let proposed = CGSize(
//                    width: lastOffset.width + value.translation.width,
//                    height: lastOffset.height + value.translation.height
//                )
//
//                // ✅ 화면 밖으로 나가 gap 생기면 끝에 “붙도록” 클램프
//                offset = clampedOffset(proposed, scale: scale, side: side, containerSize: containerSize)
//            }
//            .onEnded { _ in
//                lastOffset = offset
//            }
            .onChanged { value in
                // ✅ scale이 1보다 클 때만 이동 가능
                guard scale > 1.0 else { return }
                
                // ✅ 드래그 중에는 화면 밖으로 나가도 허용
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                guard scale > 1.0 else { return }
                
                // ✅ 손 떼면 화면 끝에 "붙게" 스냅 애니메이션
                let snapped = clampedOffset(offset, scale: scale, side: side, containerSize: containerSize)
                
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    offset = snapped
                }
                lastOffset = snapped
            }
    }

    private func magnificationGesture(side: CGFloat, containerSize: CGSize) -> some Gesture {
        MagnificationGesture()
//            .onChanged { value in
//                let newScale = lastScale * value
//                scale = newScale
//
//                // 핀치 중에도 offset이 유효 범위를 벗어나지 않게 보정
//                offset = clampedOffset(offset, scale: scale, side: side, containerSize: containerSize)
//            }
//            .onEnded { _ in
//                withAnimation(.spring()) {
//                    scale = min(max(scale, 1.0), 4.0)
//                    lastScale = scale
//
//                    // 스케일 확정 후 offset 재보정
//                    offset = clampedOffset(offset, scale: scale, side: side, containerSize: containerSize)
//                    lastOffset = offset
//
//                    // ✅ 다시 1배로 돌아오면 위치도 원점으로
//                    if scale == 1.0 {
//                        offset = .zero
//                        lastOffset = .zero
//                    }
//                }
//            }
            .onChanged { value in
                scale = lastScale * value
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    scale = min(max(scale, 1.0), 4.0)
                    lastScale = scale
                    
                    // ✅ 스케일 확정 후 오프셋도 스냅
                    let snapped = clampedOffset(offset, scale: scale, side: side, containerSize: containerSize)
                    offset = snapped
                    lastOffset = snapped
                    
                    // 1배면 원위치로
                    if scale == 1.0 {
                        offset = .zero
                        lastOffset = .zero
                    }
                }
            }
    }
}

#Preview {
    MainView()
}
