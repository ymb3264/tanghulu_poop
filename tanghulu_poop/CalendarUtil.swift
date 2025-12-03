//
//  CalendarUtil.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 12/3/25.
//

import SwiftUI

class CalendarUtil {
    static func isBetweenDec1AndDec26() -> Bool {
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
}
