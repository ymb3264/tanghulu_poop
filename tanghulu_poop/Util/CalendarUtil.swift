//
//  CalendarUtil.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 12/3/25.
//

import SwiftUI

class CalendarUtil {
    static func isBetweenDec1AndDec25() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        
        let startComp = DateComponents(year: year, month: 12, day: 1)
        let endComp   = DateComponents(year: year, month: 12, day: 25,
                                       hour: 23, minute: 59, second: 59)
        
        guard
            let startDate = calendar.date(from: startComp),
            let endDate = calendar.date(from: endComp)
        else { return false }
        
        return (startDate...endDate).contains(now)
    }
    
    static func isInFirstWeekOfMonth() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        return calendar.component(.weekOfMonth, from: now) == 1
    }
    
    static func weekdaySymbol(_ weekday: Int, locale: Locale) -> String {
        var calendar = Calendar.current
        calendar.locale = locale
        let symbols = calendar.shortWeekdaySymbols // "일", "월", ...
        return symbols[weekday - 1]
    }
    
    static func displayHour(_ hour24: Int) -> String {
        switch hour24 {
        case 0: return "오전 12시"
        case 1..<12: return "오전 \(hour24)시"
        case 12: return "오후 12시"
        default: return "오후 \(hour24 - 12)시"
        }
    }
    
    static func displayHourNoMeridiem(_ hour24: Int) -> String {
        let h = hour24 % 12
        return "\(h == 0 ? 12 : h)시"
    }
}
