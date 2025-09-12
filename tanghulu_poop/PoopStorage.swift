//
//  PoopStorage.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 5/5/25.
//

import Foundation

class PoopStorage {
    private let key = "savedDates"
    
    func save(date: Date, size: Size) {
        var poopInfos = load()

        // 같은 날짜 항목은 제거
        poopInfos.removeAll { Calendar.current.isDate($0.date, inSameDayAs: date) }

        // 새 항목 추가
        poopInfos.append(PoopInfo(date: date, size: size))

        // 저장
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(poopInfos) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func load() -> [PoopInfo] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([PoopInfo].self, from: data)) ?? []
    }
    
    func remove(date: Date) {
        var poopInfos = load()
        
        // 날짜만 같으면 모두 제거 (size 상관 없음)
        poopInfos.removeAll {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
        
        persist(poopInfos)
    }

    private func persist(_ poopInfos: [PoopInfo]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(poopInfos) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: key)
        print("🧹 Local poop data cleared.")
    }
}

struct PoopInfo: Codable, Equatable {
    let date: Date
    let size: Size
}

enum Size: String, Codable, CaseIterable {
    case small
    case medium
    case big
    case tremendous
    case diarrhea
}
