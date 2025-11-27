//
//  ContentView.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 5/5/25.
//

import SwiftUI
import Kingfisher

struct HomeView: View {
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var savedPoop: [PoopInfo] = []
    @State private var products: [PoopProduct] = []
    @State private var userVotes: [UserProductVote] = []
    @State private var text: String = ""

    let poopService = PoopService()
    let productService = PoopProductsService()
    let years = Array(2025...2030)
    let months = Array(1...12)
    
    var body: some View {
        let ranked = rankedProducts(products)
        
        ScrollView {
            VStack {
                // 🔽 년/월 선택 Picker
                HStack {
                    Picker("연도", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text("\(String(format: "%d", year))년").tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                    .clipped()
                    
                    Picker("월", selection: $selectedMonth) {
                        ForEach(months, id: \.self) { month in
                            Text("\(month)월").tag(month)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80)
                    .clipped()
                }
                .frame(height: 100)
                
                // 🔽 선택된 년/월 표시
                Text("\(String(format: "%d", selectedYear))년 \(selectedMonth)월")
                    .font(.title2)
                    .padding(.bottom, 8)
                
                // 🔽 요일 헤더
                HStack {
                    ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // 🔽 날짜 그리드
                // TODO: 코드 따로 빼기
                let days = generateDays(year: selectedYear, month: selectedMonth)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days.indices, id: \.self) { index in
                        let day = days[index]
                        
                        if day != 0 {
                            let currentDate = makeDate(year: selectedYear, month: selectedMonth, day: day)
                            
                            Menu {
                                if let currentDate {
                                    let poopList = savedPoop.filter { isSameDay($0.date, currentDate) }
                                    
                                    Menu("➕ 똥 추가") {
                                        ForEach(Size.allCases, id: \.self) { size in
                                            Button(size.rawValue) {
                                                Task {
                                                    updateLocalPoopInfo(date: currentDate, size: size)
                                                    try await poopService.savePoop(date: currentDate, size: size)
                                                }
                                            }
                                        }
                                    }
                                    
                                    if poopList.count > 0 {
                                        Menu("🛠️ 똥 변경") {
                                            if poopList.count == 1 {
                                                let poopInfo = poopList.first!
                                                
                                                ForEach(Size.allCases, id: \.self) { size in
                                                    Button("\(poopInfo.size == size ? "✔️ " : "")\(size.rawValue)") {
                                                        Task {
                                                            updateLocalPoopInfo(date: poopInfo.date, size: size)
                                                            try await poopService.savePoop(date: poopInfo.date, size: size)
                                                        }
                                                    }
                                                }
                                                
                                            } else if poopList.count > 1 {
                                                ForEach(poopList.indices, id: \.self) { index in
                                                    let poopInfo = poopList[index]
                                                    Menu("\(poopInfo.size.rawValue) \(getTime(date: poopInfo.date))") {
                                                        ForEach(Size.allCases, id: \.self) { size in
                                                            Button("\(poopInfo.size == size ? "✔️ " : "")\(size.rawValue)") {
                                                                Task {
                                                                    updateLocalPoopInfo(date: poopInfo.date, size: size)
                                                                    try await poopService.savePoop(date: poopInfo.date, size: size)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if poopList.count == 1 {
                                            let poopInfo = poopList.first!
                                            
                                            Button("🧹 똥 제거") {
                                                Task {
                                                    updateLocalPoopInfo(date: poopInfo.date, size: nil)
                                                    try await poopService.deletePoop(date: poopInfo.date)
                                                }
                                            }
                                        } else if poopList.count > 1 {
                                            Menu("🧹 똥 제거") {
                                                ForEach(poopList.indices, id: \.self) { index in
                                                    let poopInfo = poopList[index]
                                                    Button("\(poopInfo.size.rawValue) \(getTime(date: poopInfo.date))") {
                                                        Task {
                                                            updateLocalPoopInfo(date: poopInfo.date, size: nil)
                                                            try await poopService.deletePoop(date: poopInfo.date)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } label: {
                                VStack(spacing: 0) {
                                    Text("\(day)")
                                        .frame(maxWidth: .infinity)
                                    
                                    if let currentDate {
                                        let poopList = savedPoop.filter { isSameDay($0.date, currentDate) }
                                        
                                        if poopList.count > 0 {
                                            let poopInfo = poopList.first!
                                            let poopSize: CGFloat = switch poopInfo.size {
                                            case .small: 15
                                            case .medium: 21
                                            case .big: 26
                                            case .tremendous: 30
                                            case .diarrhea: 21
                                            case .product: 0
                                            }
                                            let sizeText: String = switch poopInfo.size {
                                            case .small: "s"
                                            case .medium: "m"
                                            case .big: "b"
                                            case .tremendous: "T"
                                            case .diarrhea: "di"
                                            case .product: "P"
                                            }
                                            
                                            if poopInfo.size != .product {
                                                ZStack {
                                                    Text(poopInfo.size == .diarrhea ? "🤢" : "💩")
                                                        .font(.system(size: poopSize))
                                                    
                                                    HStack {
                                                        Text(sizeText)
                                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                                            .font(.system(size: 10))
                                                            .foregroundStyle(.secondary)
                                                        
                                                        if poopList.count > 1 {
                                                            Text("+\(poopList.count)")
                                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                                                .font(.system(size: 10))
                                                                .foregroundStyle(.secondary)
                                                        }
                                                    }
                                                }
                                                .frame(height: 40)
                                                
                                                Text(getTime(date: poopInfo.date))
                                                    .font(.system(size: 11))
                                            }
                                        } else {
                                            Text("")
                                                .frame(height: 40)
                                            Text("")
                                        }
                                    }
                                    //                                else {
                                    //                                    Text("")
                                    //                                        .frame(height: 40)
                                    //                                    Text("")
                                    //                                }
                                }
                            }
                            .foregroundStyle(.primary)
                        } else {
                            VStack(spacing: 0) {
                                Text("")
                                    .frame(maxWidth: .infinity)
                                Text("")
                                    .frame(height: 40)
                                Text("")
                            }
                        }
                    }
                }
                
                // 제품 추천 리스트
                Text("나한테는 이게 효과가 좋더라 🧃")
                    .font(.system(size: 18))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 26)
                    .background(
                        RoundedRectangle(cornerRadius: 20).stroke(.pink, lineWidth: 2)
                    )

                // TODO:
                // - 제품 먹은거 캘린더에 추가
                // - 이미지 확대
                // - 추천 햅틱?
                // - 추천 추가/취소 시 PoopProducts의 recommendCount도 수정되게
                // - 제품 추천(추가) 기능
                // - 추천 왼쪽 또는 오른쪽 위에 설명 (제품 추천 시 관리자가 확인 후 리스트에 추가함)
                // - 제품 최대 노출 10개, ScrollView로
                ForEach(Array(ranked.enumerated()), id: \.element.product.productId) { _, item in
                    let rank = item.rank
                    let product = item.product
                    let productId = product.productId
                    let isVoted = userVotes.contains(where: { $0.productId == productId })
                    
                    HStack {
                        Text("\(rank)")
                            .frame(width: 30)
                        
                        Text(product.name)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        if let url = product.imageUrl {
                            KFImage(URL(string: url))
                                .placeholder {
                                    ProgressView()
                                }
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        
                        Button(action: {
                            if isVoted {
                                Task {
                                    try await productService.cancelVote(productId: productId)
                                    userVotes.removeAll { $0.productId == productId }
                                }
                            } else {
                                Task {
                                    try await productService.addVote(date: Date(), productId: productId)
                                    userVotes.append(UserProductVote(productId: productId))
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
                }
            }
            .padding()
        }
        .onAppear {
            Task {
                do {
                    try await poopService.loadAllPoop(completion: { poop in
                        savedPoop = poop
                    })
                    try await productService.loadProducts(completion: { products in
                        self.products = products
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
    
    // 날짜 배열 생성
    func generateDays(year: Int, month: Int) -> [Int] {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_KR")
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let firstDayOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return []
        }
        
        let weekday = calendar.component(.weekday, from: firstDayOfMonth) // 1 = 일요일
        let days = Array(repeating: 0, count: weekday - 1) + Array(range)
        return days
    }
    
    func makeDate(year: Int, month: Int, day: Int) -> Date? {
        let now = Date()
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: now)
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = timeComponents.second
        
        return calendar.date(from: components)
    }
    
    func isSameDay(_ d1: Date, _ d2: Date) -> Bool {
        Calendar.current.isDate(d1, inSameDayAs: d2)
    }
    
//    func getPoopInfo(year: Int, month: Int, day: Int) -> PoopInfo? {
//        let calendar = Calendar.current
//        guard let targetDate = calendar.date(from: DateComponents(year: year, month: month, day: day)) else {
//            return nil
//        }
//        
//        return savedPoop.first {
//            isSameDay($0.date, targetDate)
//        }
//    }
    
    func isSameMoment(_ d1: Date, _ d2: Date) -> Bool {
        return d1 == d2
    }
    
    func getTime(date: Date) -> String {
        guard let poopInfo = savedPoop.first(where: { isSameMoment($0.date, date) }) else {
           return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        return formatter.string(from: poopInfo.date)
    }
    
    func updateLocalPoopInfo(date: Date, size: Size?) {
        if let index = savedPoop.firstIndex(where: { isSameMoment($0.date, date) }) {
            if let size {
                savedPoop[index] = PoopInfo(date: date, size: size)
            } else {
                savedPoop.remove(at: index)
            }
        } else {
            if let size {
                savedPoop.append(PoopInfo(date: date, size: size))
            }
        }
    }
    
    func rankedProducts(_ products: [PoopProduct]) -> [(rank: Int, product: PoopProduct)] {
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
}

#Preview {
    HomeView()
}
