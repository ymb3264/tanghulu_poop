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
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
