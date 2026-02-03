//
//  PoopReportBuilder.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 2/3/26.
//

import Foundation

struct PoopReportBuilder {
    private let calendar: Calendar = .current
    private let locale: Locale = Locale(identifier: "ko_KR")
    
    func dayOfWeekReport(savedPoop: [PoopInfo]) -> String {
        // 1) 기간 상관없이 6일 이상 기록된 경우: 최빈 요일 1~2위
        if hasAtLeast6DistinctDays(in: savedPoop) {
            let topDays = topWeekdays(from: savedPoop, top: 2)
            if !topDays.isEmpty {
                return topDays.joined(separator: "·")
            }
        }
        
        return ""
    }
    
    func hourReport(savedPoop: [PoopInfo]) -> String {
        let lastMonthPoop = filterLastMonth(savedPoop)
        
        // 2) 지난달 6일 이상 기록된 경우: 최빈 시간(시간대)
        if hasAtLeast6DistinctDays(in: lastMonthPoop) {
            if let (hour, minuteBucket) = mostFrequentTimeBucket(from: lastMonthPoop) {
                return formatHourBucket(hour: hour, minuteBucket: minuteBucket)
            }
        }
        
        return ""
    }
    
    func sizeReport(savedPoop: [PoopInfo]) -> String {
        let lastMonthPoop = filterLastMonth(savedPoop)
        
        // 3) 지난달 6일 이상 기록된 경우: 최빈 사이즈
        if hasAtLeast6DistinctDays(in: lastMonthPoop) {
            if let topSize = mostFrequentSize(from: lastMonthPoop) {
                return topSize.text
            }
        }
        
        return ""
    }
    
    private func hasAtLeast6DistinctDays(in poops: [PoopInfo]) -> Bool {
        let days = Set(poops.map { calendar.startOfDay(for: $0.date) })
        return days.count >= 6
    }
    
    private func topWeekdays(
        from poops: [PoopInfo],
        top: Int
    ) -> [String] {
        // weekday: 1(일)~7(토)
        var counts: [Int: Int] = [:]
        for p in poops {
            let w = calendar.component(.weekday, from: p.date)
            counts[w, default: 0] += 1
        }
        
        // 1) count 내림차순, 동률이면 요일(일~토) 오름차순
        let sorted = counts.sorted { a, b in
            if a.value != b.value { return a.value > b.value }
            return a.key < b.key
        }
        
        // 2) top번째(예: 2등) 컷의 count 구하기
        let index = min(top - 1, sorted.count - 1)
        let cutoffCount = sorted[index].value
        
        // 3) cutoff 이상인 애들은 동률 포함해서 모두 선택
        let picked = sorted
            .filter { $0.value >= cutoffCount }
            .map { CalendarUtil.weekdaySymbol($0.key, locale: locale) }
        
        return picked
    }

    private func filterLastMonth(_ poops: [PoopInfo]) -> [PoopInfo] {
        let now = Date()
        let startOfThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        // 지난달 1일 00:00
        let startOfLastMonth = calendar.date(byAdding: .month, value: -1, to: startOfThisMonth)!
        return poops.filter { $0.date >= startOfLastMonth && $0.date < startOfThisMonth }
    }

    /// 기본은 "시간 단위"로 최빈값. (예: 7시)
    /// minuteBucket을 쓰면 30분 단위 같은 확장도 가능: 0 or 30
    private func mostFrequentTimeBucket(
        from poops: [PoopInfo],
        minuteStep: Int = 60
    ) -> (hour: Int, minuteBucket: Int)? {
        guard !poops.isEmpty else { return nil }

        var counts: [String: Int] = [:] // "HH:mmBucket"
        for p in poops {
            let hour = calendar.component(.hour, from: p.date)
            let minute = calendar.component(.minute, from: p.date)
            let bucket = (minute / minuteStep) * minuteStep // 0 (시간단위면 항상 0)
            let key = "\(hour):\(bucket)"
            counts[key, default: 0] += 1
        }

        guard let best = counts.max(by: { $0.value < $1.value }) else { return nil }
        let parts = best.key.split(separator: ":")
        let hour = Int(parts[0]) ?? 0
        let bucket = Int(parts[1]) ?? 0
        return (hour, bucket)
    }

    private func formatHourBucket(hour: Int, minuteBucket: Int) -> String {
        if minuteBucket == 0 {
            let nextHour = (hour + 1) % 24
            return "\(CalendarUtil.displayHour(hour))~\(CalendarUtil.displayHourNoMeridiem(nextHour))" // 예: "오전 7시~8시", "오후 11시~12시"
        } else {
            return "\(CalendarUtil.displayHour(hour)) \(minuteBucket)분대"
        }
    }

    private func mostFrequentSize(from poops: [PoopInfo]) -> Size? {
        let filtered = poops.filter { $0.size != .product } // displayCases 기준
        guard !filtered.isEmpty else { return nil }

        var counts: [Size: Int] = [:]
        for p in filtered {
            counts[p.size, default: 0] += 1
        }

        return counts.max(by: { $0.value < $1.value })?.key
    }
}
