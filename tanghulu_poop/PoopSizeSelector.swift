//
//  PoopSize.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 5/7/25.
//

import SwiftUI

struct PoopSizeSelector: View {
    @State private var isFirstSelected = false
    @State private var isSecondSelected = false
    @State private var isThirdSelected = false
    @State private var isFourthSelected = false
    @State private var isFifthSelected = false
    
    @Binding var isSelected: Bool
    
//    let storage = PoopStorage()
    let storage = PoopStorageService()
    
    var body: some View {
        VStack {
            Text("오늘 똥의 크기는 어떤가요?")
                .font(.system(size: 20))
                .padding(.bottom, 8)
                .padding(.horizontal, 10)
                .overlay {
                    VStack {
                        Spacer()
                        Rectangle().fill(.blue).frame(height: 2)
                    }
                }
                .padding(.bottom)
            
            Button(action: {
                isFirstSelected.toggle()
                storage.savePoop(date: Date(), size: .small)
                isSelected.toggle()
            }) {
                Text("small")
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .font(.system(size: 15, weight: .semibold))
                    .background(
                        isFirstSelected ?
                        AnyView(RoundedRectangle(cornerRadius: 20).fill(Color.brown)) :
                            AnyView(RoundedRectangle(cornerRadius: 20).stroke(Color.brown, lineWidth: 2))
                    )
                    .padding(.horizontal)
            }
            .foregroundStyle(isFirstSelected ? .white : .brown)
            
            Button(action: {
                isSecondSelected.toggle()
                storage.savePoop(date: Date(), size: .medium)
                isSelected.toggle()
            }) {
                Text("medium")
                    .frame(maxWidth: .infinity, maxHeight: 47)
                    .font(.system(size: 22, weight: .semibold))
                    .background(
                        isSecondSelected ?
                        AnyView(RoundedRectangle(cornerRadius: 27).fill(Color.brown)) :
                            AnyView(RoundedRectangle(cornerRadius: 27).stroke(Color.brown, lineWidth: 2))
                    )
                    .padding(.horizontal)
            }
            .foregroundStyle(isSecondSelected ? .white : .brown)
            
            Button(action: {
                isThirdSelected.toggle()
                storage.savePoop(date: Date(), size: .big)
                isSelected.toggle()
            }) {
                Text("big")
                    .frame(maxWidth: .infinity, maxHeight: 53)
                    .font(.system(size: 28, weight: .semibold))
                    .background(
                        isThirdSelected ?
                        AnyView(RoundedRectangle(cornerRadius: 33).fill(Color.brown)) :
                            AnyView(RoundedRectangle(cornerRadius: 33).stroke(Color.brown, lineWidth: 2))
                    )
                    .padding(.horizontal)
            }
            .foregroundStyle(isThirdSelected ? .white : .brown)
            
            Button(action: {
                isFourthSelected.toggle()
                storage.savePoop(date: Date(), size: .tremendous)
                isSelected.toggle()
            }) {
                Text("tremendous")
                    .frame(maxWidth: .infinity, maxHeight: 59)
                    .font(.system(size: 34, weight: .semibold))
                    .background(
                        isFourthSelected ?
                        AnyView(RoundedRectangle(cornerRadius: 39).fill(Color.brown)) :
                            AnyView(RoundedRectangle(cornerRadius: 39).stroke(Color.brown, lineWidth: 2))
                    )
                    .padding(.horizontal)
            }
            .foregroundStyle(isFourthSelected ? .white : .brown)
            
            Button(action: {
                isFifthSelected.toggle()
                storage.savePoop(date: Date(), size: .diarrhea)
                isSelected.toggle()
            }) {
                VStack(spacing: 0) {
                    Text("diarrhea")
                        .frame(maxWidth: .infinity, maxHeight: 47)
                        .font(.system(size: 22, weight: .semibold))
                        .background(
                            isFifthSelected ?
                            AnyView(RoundedRectangle(cornerRadius: 27).fill(Color.brown)) :
                                AnyView(EmptyView())
                        )
                        .padding(.horizontal)
                    
                    if !isFifthSelected {
                        WaveLine(waveHeight: 6, waveLength: 20)
                            .stroke(Color.brown, lineWidth: 2)
                            .frame(height: 1)
                            .padding(.horizontal, 40)
                    }
                }
            }
            .foregroundStyle(isFifthSelected ? .white : .brown)
        }
    }
}

//#Preview {
//    PoopSizeSelector()
//}
