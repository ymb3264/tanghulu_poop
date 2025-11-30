//
//  WavyRectangle.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 5/20/25.
//

import SwiftUI

struct WaveLine: Shape {
    var waveHeight: CGFloat = 10
    var waveLength: CGFloat = 20

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let step = waveLength
        let halfStep = step / 2

        var x: CGFloat = rect.minX
        let midY = rect.midY

        path.move(to: CGPoint(x: x, y: midY))

        while x <= rect.maxX {
            let control1 = CGPoint(x: x + halfStep / 2, y: midY - waveHeight)
            let end1 = CGPoint(x: x + halfStep, y: midY)
            path.addQuadCurve(to: end1, control: control1)

            let control2 = CGPoint(x: x + halfStep + halfStep / 2, y: midY + waveHeight)
            let end2 = CGPoint(x: x + step, y: midY)
            path.addQuadCurve(to: end2, control: control2)

            x += step
        }

        return path
    }
}


#Preview {
    VStack(spacing: 0) {
        Button(action: {
        }) {
            VStack(spacing: 0) {
                Text("diarrhea")
                    .frame(maxWidth: .infinity, maxHeight: 47)
                    .font(.system(size: 22, weight: .semibold))
//                    .background(
//                        isFifthSelected ?
//                        AnyView(RoundedRectangle(cornerRadius: 27).fill(Color.brown)) :
//                            AnyView(EmptyView())
//                    )
                    .padding(.horizontal)
                
                WaveLine(waveHeight: 6, waveLength: 20)
                    .stroke(Color.brown, lineWidth: 2)
                    .frame(height: 1)
                    .padding(.horizontal, 40)
            }
        }
        .foregroundStyle(.brown)
    }
}
