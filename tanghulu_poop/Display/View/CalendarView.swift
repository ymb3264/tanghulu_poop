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
    @State private var isEventDescOpened = false
    
    // report
    @State private var isReportOpened = false
    @State private var hasReport = false
    @State private var reportDayOfWeek = ""
    @State private var reportHour = ""
    @State private var reportSize = ""
    
    private let years = Array(2025...2030)
    private let months = Array(1...12)
    
    private let poopService = PoopService()
    
    @AppStorage("isNormalMode") private var isNormalModeRaw = true
    private var isNormalModeEffective: Bool {
//        if !CalendarUtil.isBetweenDec1AndDec26() {
//            // 범위 밖이면 저장값이 뭐든 무조건 true
//            return true
//        } else {
//            // 범위 안이면:
//            //  저장값이 없으면 false
//            //  저장값이 있으면 그 값 사용
//            //
//            // AppStorage는 "없으면 default true"라서
//            // '없음'을 구분하려면 UserDefaults를 직접 확인해야 함.
//            let hasStoredValue = UserDefaults.standard.object(forKey: "isNormalMode") != nil
//            return hasStoredValue ? isNormalModeRaw : false
//        }
        
        // 1) 오늘이 이벤트 기간(12/1~12/25)인지
        guard CalendarUtil.isBetweenDec1AndDec25() else {
            return true
        }
        
        // 2) 선택된 달력이 "현재년도 12월"인지
        let currentYear = Calendar.current.component(.year, from: Date())
        let isViewingCurrentDecember = (selectedYear == currentYear && selectedMonth == 12)
        
        // 이벤트 기간이더라도 현재년도 12월을 보고 있지 않으면 무조건 true
        guard isViewingCurrentDecember else {
            return true
        }
        
        // 3) (이벤트 기간 + 현재년도 12월을 보고 있을 때만) 기존 저장 로직 적용
        let hasStoredValue = UserDefaults.standard.object(forKey: "isNormalMode") != nil
        return hasStoredValue ? isNormalModeRaw : false
    }
    private var isEventToggleShowing: Bool {
        // 1) 오늘이 이벤트 기간(12/1~12/25)인지
        guard CalendarUtil.isBetweenDec1AndDec25() else {
            return false
        }
        
        // 2) 선택된 달력이 "현재년도 12월"인지
        // 이벤트 기간이더라도 현재년도 12월을 보고 있지 않으면 무조건 false
        let currentYear = Calendar.current.component(.year, from: Date())
        return (selectedYear == currentYear && selectedMonth == 12)
    }
    
    private var isReportShowing: Bool {
        // 1) 매달 첫째주에만
        return CalendarUtil.isInFirstWeekOfMonth()
    }
    
//    init(productNames: Binding<[String]>) {
//        self._productNames = productNames
//        UserDefaults.standard.removeObject(forKey: "isNormalMode")
//    }
    
    var body: some View {
        VStack {
            if isEventToggleShowing {
                if !isEventDescOpened {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isEventDescOpened = true
                        }
                    }) {
                        Text("클릭 🎄")
                    }
                    .foregroundStyle(.secondary)
                }
                
                if isEventDescOpened {
                    VStack(spacing: 12) {
                        Text("12월 25일")
                            .foregroundStyle(.darkRed)
                        + Text("까지 똥이 🎄로 표시됩니다.")
                            .foregroundStyle(.darkGreen)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                if isNormalModeEffective {
                                    isNormalModeRaw = false
//                                    UserDefaults.standard.set(false, forKey: "isNormalMode")
                                } else {
                                    isNormalModeRaw = true
//                                    UserDefaults.standard.set(true, forKey: "isNormalMode")
                                }
                            }) {
                                Text(isNormalModeEffective ? "옵션 켜기" : "옵션 끄기")
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .overlay {
                                        Capsule()
                                            .stroke(.secondary, lineWidth: 1)
                                    }
                            }
                            .foregroundStyle(.secondary)
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isEventDescOpened = false
                                }
                            }) {
                                Text("닫기")
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .overlay {
                                        Capsule()
                                            .stroke(.secondary, lineWidth: 1)
                                    }
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            if isReportShowing {
                VStack(alignment: .leading, spacing: 6) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isReportOpened = !isReportOpened
                        }
                    }) {
                        Text("내 똥 분석 리포트 📋")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.primary)
                    
                    if isReportOpened {
                        Text("※ 내 똥 분석 리포트는 매달 첫째주에만 노출됩니다.")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 4)
                        
                        if hasReport {
                            Text("주로 ")
                            + Text("\(reportDayOfWeek)요일").fontWeight(.bold)
                            + Text("에 화장실을 방문하는 편이에요.")
                            
                            Text("지난달에는 ")
                            + Text(reportHour).fontWeight(.bold)
                            + Text("에 가장 자주 방문했어요.")
                            
                            Text("지난달 가장 많이 기록된 사이즈는")
                            + Text(" \(reportSize) ").fontWeight(.bold)
                            + Text("이었습니다.")
                        } else {
                            Text("지날달 6일 이상의 똥 기록이 있을 경우에만 분석 리포트가 제공됩니다.")
                        }
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isReportOpened = false
                            }
                        }) {
                            Text("닫기")
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .overlay {
                                    Capsule()
                                        .stroke(.secondary, lineWidth: 1)
                                }
                        }
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                    }
                }
            }

            
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
                .onChange(of: selectedYear) {
                    
                }
                
                Picker("월", selection: $selectedMonth) {
                    ForEach(months, id: \.self) { month in
                        Text("\(month)월").tag(month)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80)
                .clipped()
                .onChange(of: selectedMonth) {
                    
                }
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
//                                let productList = savedPoop.filter { $0.size == .product && isSameDay($0.date, currentDate) }
                                
                                Menu("➕ 똥 추가") {
                                    ForEach(Size.displayCases, id: \.self) { size in
                                        let label = size == .rabbit ? "\(size.rawValue) 🐰" : size.rawValue
                                        Button(label) {
                                            Task {
                                                if let now = makeDate(year: selectedYear, month: selectedMonth, day: day) {
                                                    updateLocalPoopInfo(date: now, size: size)
                                                    try await poopService.savePoop(date: now, size: size)
                                                }
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
                                
//                                Menu("🧃 제품 추가") {
//                                    ForEach(productNames, id: \.self) { name in
//                                        Button(name) {
//                                            Task {
//                                                if let now = makeDate(year: selectedYear, month: selectedMonth, day: day) {
//                                                    updateLocalPoopInfo(date: now, size: .product, productName: name)
//                                                    try await poopService.savePoop(date: now, size: .product, productName: name)
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
                                
//                                if productList.count == 1 {
//                                    let productInfo = productList.first!
//                                    
//                                    Button("🧹 제품 제거") {
//                                        Task {
//                                            updateLocalPoopInfo(date: productInfo.date, size: nil)
//                                            try await poopService.deletePoop(date: productInfo.date)
//                                        }
//                                    }
//                                } else if productList.count > 1 {
//                                    Menu("🧹 제품 제거") {
//                                        ForEach(productList.indices, id: \.self) { index in
//                                            let productInfo = productList[index]
//                                            Button("\(productInfo.productName ?? productInfo.size.rawValue) \(getTime(date: productInfo.date))") {
//                                                Task {
//                                                    updateLocalPoopInfo(date: productInfo.date, size: nil)
//                                                    try await poopService.deletePoop(date: productInfo.date)
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
                            }
                        } label: {
                            VStack(spacing: 0) {
                                Text("\(day)")
                                    .frame(maxWidth: .infinity)
                                
                                if let currentDate {
                                    let poopList = savedPoop.filter { $0.size != .product && isSameDay($0.date, currentDate) }
//                                    let productList = savedPoop.filter { $0.size == .product && isSameDay($0.date, currentDate) }
                                    
                                    if poopList.count == 0 {
                                        VStack(spacing: 0) {
//                                            HStack {
//                                                VStack {
//                                                    if productList.count > 0 {
//                                                        Circle()
//                                                            .fill(.moare)
//                                                            .frame(width: 8, height: 8)
//                                                    }
//                                                }
//                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
//                                            }
                                            
                                            Text("")
                                        }
                                        .frame(height: 60)
                                    } else if poopList.count == 1 {
                                        let poopInfo = poopList.first!
                                        let poopSize: CGFloat = switch poopInfo.size {
                                        case .small, .rabbit: 15
                                        case .medium: 21
                                        case .big: 26
                                        case .tremendous: 30
                                        case .diarrhea: 21
                                        case .product: 0
                                        }
                                        let poopEmoji: String = switch poopInfo.size {
                                        case .small, .medium, .big, .tremendous: "💩"
                                        case .diarrhea: "🤢"
                                        case .product: ""
                                        case .rabbit: "🐰"
                                        }
                                        
                                        VStack(spacing: 0) {
                                            ZStack {
                                                if isNormalModeEffective {
                                                    Text(poopEmoji)
                                                        .font(.system(size: poopSize))
                                                } else {
                                                    Text("🎄")
                                                        .font(.system(size: poopSize))
                                                }
                                                
                                                HStack {
                                                    Text(poopInfo.size.text)
                                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                                        .font(.system(size: 10))
                                                        .foregroundStyle(.secondary)
                                                    
//                                                    VStack(spacing: 2) {
//                                                        if productList.count > 0 {
//                                                            Circle()
//                                                                .fill(.moare)
//                                                                .frame(width: 8, height: 8)
//                                                        }
//                                                    }
//                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                                }
                                            }
                                            
                                            Text(getTime(date: poopInfo.date))
                                                .font(.system(size: 11))
                                        }
                                        .frame(height: 60)
                                    }  else if poopList.count > 1 {
                                        VStack(spacing: 0) {
                                            HStack {
                                                Spacer()
                                                
                                                Text("+\(poopList.count)")
                                                    .font(.system(size: 10))
                                                    .foregroundStyle(.secondary)
                                                
//                                                if productList.count > 0 {
//                                                    Circle()
//                                                        .fill(.moare)
//                                                        .frame(width: 8, height: 8)
//                                                }
                                            }
                                            .padding(.bottom, 2)
                                            
                                            // 최대 3개까지만
                                            ForEach(Array(poopList.indices.prefix(3)), id: \.self) { index in
                                                let poopInfo = poopList[index]
                                                
                                                HStack(spacing: 0) {
                                                    Text(getTime(date: poopInfo.date))
                                                        .font(.system(size: 11))
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                    
                                                    Text(poopInfo.size.text)
                                                        .font(.system(size: 11))
                                                        .fontWeight(.semibold)
                                                        .foregroundStyle(.secondary)
                                                }
                                                .padding(.bottom, 3)
                                            }
                                        }
                                        .frame(height: 60)
                                    } else {
                                        Text("")
                                            .frame(height: 40)
                                        Text("")
                                    }
                                }
                            }
                            .overlay {
                                if let currentDate, Calendar.current.isDate(currentDate, inSameDayAs: Date()) {
                                    RoundedRectangle(cornerRadius: 10).stroke(.green, lineWidth: 1)
                                    .padding(.vertical, -2)
                                    .padding(.horizontal, -3)
                                }
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
                        
                        // report 생성
                        let reportBuilder = PoopReportBuilder()
                        reportDayOfWeek = reportBuilder.dayOfWeekReport(savedPoop: savedPoop)
                        reportHour = reportBuilder.hourReport(savedPoop: savedPoop)
                        reportSize = reportBuilder.sizeReport(savedPoop: savedPoop)
                        
                        if !reportDayOfWeek.isEmpty && !reportHour.isEmpty && !reportSize.isEmpty {
                            isReportOpened = true
                            hasReport = true
                        } else {
                            isReportOpened = false
                            hasReport = false
                        }
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
