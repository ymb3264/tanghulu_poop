//
//  TestView.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 11/30/25.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        VStack {
            Text("🎉 전송되었습니다 🎉")
                .foregroundStyle(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20).fill(.moare).opacity(0.8)
                )
        }
        .padding()
    }
}

#Preview {
    TestView()
}
