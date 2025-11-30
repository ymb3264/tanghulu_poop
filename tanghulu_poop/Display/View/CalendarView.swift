//
//  CalendarView.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 11/29/25.
//

import SwiftUI

struct CalendarView: View {
    @Binding var productNames: [String]
    
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var savedPoop: [PoopInfo] = []
    
    private let years = Array(2025...2030)
    private let months = Array(1...12)
    
    private let poopService = PoopService()
    
    var body: some View {
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
                                let poopList = savedPoop.filter { $0.size != .product && isSameDay($0.date, currentDate) }
                                let productList = savedPoop.filter { $0.size == .product && isSameDay($0.date, currentDate) }
                                
                                Menu("➕ 똥 추가") {
                                    ForEach(Size.displayCases, id: \.self) { size in
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
                                            
                                            ForEach(Size.displayCases, id: \.self) { size in
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
                                                    ForEach(Size.displayCases, id: \.self) { size in
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
                                
                                Menu("🧃 제품 추가") {
                                    ForEach(productNames, id: \.self) { name in
                                        Button(name) {
                                            Task {
                                                updateLocalPoopInfo(date: currentDate, size: .product, productName: name)
                                                try await poopService.savePoop(date: currentDate, size: .product)
                                            }
                                        }
                                    }
                                }
                                
                                if productList.count == 1 {
                                    let productInfo = productList.first!
                                    
                                    Button("🧹 제품 제거") {
                                        Task {
                                            updateLocalPoopInfo(date: productInfo.date, size: nil)
                                            try await poopService.deletePoop(date: productInfo.date)
                                        }
                                    }
                                } else if productList.count > 1 {
                                    Menu("🧹 제품 제거") {
                                        ForEach(productList.indices, id: \.self) { index in
                                            let productInfo = productList[index]
                                            Button("\(productInfo.productName ?? productInfo.size.rawValue) \(getTime(date: productInfo.date))") {
                                                Task {
                                                    updateLocalPoopInfo(date: productInfo.date, size: nil)
                                                    try await poopService.deletePoop(date: productInfo.date)
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
                                    let poopList = savedPoop.filter { $0.size != .product && isSameDay($0.date, currentDate) }
                                    let productList = savedPoop.filter { $0.size == .product && isSameDay($0.date, currentDate) }
                                    
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
                                        case .product: ""
                                        }
                                        
                                        ZStack {
                                            Text(poopInfo.size == .diarrhea ? "🤢" : "💩")
                                                .font(.system(size: poopSize))
                                            
                                            HStack {
                                                Text(sizeText)
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                                    .font(.system(size: 10))
                                                    .foregroundStyle(.secondary)
                                                
                                                VStack(spacing: 2) {
                                                    if poopList.count > 1 {
                                                        Text("+\(poopList.count)")
                                                            .font(.system(size: 10))
                                                            .foregroundStyle(.secondary)
                                                    }
                                                    
                                                    if productList.count > 0 {
                                                        Circle()
                                                            .fill(.moare)
                                                            .frame(width: 8, height: 8)
                                                    }
                                                }
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                            }
                                        }
                                        .frame(height: 40)
                                        
                                        Text(getTime(date: poopInfo.date))
                                            .font(.system(size: 11))
                                    } else {
                                        HStack {
                                            VStack {
                                                if productList.count > 0 {
                                                    Circle()
                                                        .fill(.moare)
                                                        .frame(width: 8, height: 8)
                                                }
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                        }
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
        }
        .onAppear {
            Task {
                do {
                    try await poopService.loadAllPoop(completion: { poop in
                        savedPoop = poop
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
    
    func updateLocalPoopInfo(date: Date, size: Size?, productName: String? = nil) {
        if let index = savedPoop.firstIndex(where: { isSameMoment($0.date, date) }) {
            if let size {
                savedPoop[index] = PoopInfo(date: date, size: size)
            } else {
                savedPoop.remove(at: index)
            }
        } else {
            if let size {
                savedPoop.append(PoopInfo(date: date, size: size, productName: productName))
            }
        }
    }
}
