//
//  tanghulu_poopApp.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 5/5/25.
//

import SwiftUI
import AWSCore
import AWSDynamoDB

@main
struct tanghulu_poopApp: App {
    
    init() {
        configureAWS()
//        migrateIfNeeded()
    }
    
    private func configureAWS() {
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: .APNortheast2,
            identityPoolId: "ap-northeast-2:df91376f-7110-4cbe-8cef-10d407fd802c"
        )
    
        let configuration = AWSServiceConfiguration(
            region: .APNortheast2,
            credentialsProvider: credentialsProvider
        )
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    private func migrateIfNeeded() {
        let alreadyMigrated = UserDefaults.standard.bool(forKey: "PoopMigrated")
        if !alreadyMigrated {
            migrateUserDefaultsToDynamoDB()
            UserDefaults.standard.set(true, forKey: "PoopMigrated")
        }
    }
    
    func migrateUserDefaultsToDynamoDB() {
        let localStorage = PoopStorage()
        let localData = localStorage.load()
        
        guard !localData.isEmpty else {
            print("✅ No local data to migrate.")
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let objectMapper = AWSDynamoDBObjectMapper.default()

        for item in localData {
            let model = PoopModel()
            model?.userId = "Tanghulu"
            model?.date = formatter.string(from: item.date)
            model?.size = item.size.rawValue

            objectMapper.save(model!).continueWith { task in
                if let error = task.error {
                    print("❌ Failed to migrate item on \(model!.date!): \(error)")
                } else {
                    print("✅ Migrated item for \(model!.date!)")
                }
                return nil
            }
        }
        
        // ❗️선택: 마이그레이션 완료 후 로컬 데이터 제거
        localStorage.clearAll()
    }

    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
