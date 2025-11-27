//
//  AWSService.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 11/27/25.
//

import AWSDynamoDB

struct AWSService {
    static func cognitoProvider() -> AWSCognitoCredentialsProvider {
        guard let p = AWSServiceManager.default()
            .defaultServiceConfiguration?
            .credentialsProvider as? AWSCognitoCredentialsProvider else {
            fatalError("No credentials provider configured")
        }
        return p
    }
    
    static func loadIdentityId() async throws -> String {
        let provider = cognitoProvider()
        return try await withCheckedThrowingContinuation { continuation in
            provider.getIdentityId().continueWith { task in
                if let error = task.error {
                    continuation.resume(throwing: error)
                } else if let identityId = task.result as String? {
                    continuation.resume(returning: identityId)
                } else {
                    continuation.resume(throwing: NSError(domain: "App", code: -1,
                                                          userInfo: [NSLocalizedDescriptionKey: "No identityId"]))
                }
                return nil
            }
        }
    }
}
