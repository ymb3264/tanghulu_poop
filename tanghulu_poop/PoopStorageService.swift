//
//  StorageService.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 5/16/25.
//

import AWSDynamoDB

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

enum AWSKit {
    static func cognitoProvider() -> AWSCognitoCredentialsProvider {
        guard let p = AWSServiceManager.default()
            .defaultServiceConfiguration?
            .credentialsProvider as? AWSCognitoCredentialsProvider else {
            fatalError("No credentials provider configured")
        }
        return p
    }
}

class PoopStorageService {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    private let formatter: ISO8601DateFormatter
    private let objectMapper = AWSDynamoDBObjectMapper.default()
    
    init() {
        let f = ISO8601DateFormatter()
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.formatOptions = [.withInternetDateTime] // 필요 시 .withFractionalSeconds 추가
        self.formatter = f
    }
    
    func loadIdentityId() async throws -> String {
        let provider = AWSKit.cognitoProvider()
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
    
    func savePoop(date: Date, size: Size) async throws {
        let userId = try await loadIdentityId()

        let model = PoopModel()
        model?.userId = userId
        model?.date = formatter.string(from: date)
        model?.size = size.rawValue

        objectMapper.save(model!).continueWith { task in
            if let error = task.error {
                print("Save error: \(error)")
            } else {
                print("Saved size for \(model!.date!)")
            }
            return nil
        }
    }

    func loadPoop(date: Date, completion: @escaping (Size?) -> Void) async throws {
        let userId = try await loadIdentityId()
        
        let dateString = formatter.string(from: date)

        objectMapper.load(PoopModel.self, hashKey: userId, rangeKey: dateString).continueWith { task in
            if let error = task.error {
                print("Load error: \(error)")
                completion(nil)
            } else if let result = task.result as? PoopModel,
                      let sizeRaw = result.size,
                      let size = Size(rawValue: sizeRaw) {
                completion(size)
            } else {
                completion(nil)
            }
            return nil
        }
    }
    
    func loadAllPoop(completion: @escaping ([PoopInfo]) -> Void) async throws {
        let userId = try await loadIdentityId()

        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "userId = :userId"
        queryExpression.expressionAttributeValues = [":userId": userId]

        objectMapper.query(PoopModel.self, expression: queryExpression).continueWith { task in
            if let error = task.error {
                print("❌ Query error: \(error)")
                completion([])
            } else if let results = task.result?.items as? [PoopModel] {
                let poopInfos: [PoopInfo] = results.compactMap { item in
                    guard
                        let dateString = item.date,
                        let date = self.formatter.date(from: dateString),
                        let sizeRaw = item.size,
                        let size = Size(rawValue: sizeRaw)
                    else {
                        return nil
                    }
                    return PoopInfo(date: date, size: size)
                }

                completion(poopInfos)
            } else {
                completion([])
            }
            return nil
        }
    }
    
//    func deletePoop(for userId: String = "mobul", date: Date, completion: @escaping (Bool) -> Void) {
    func deletePoop(date: Date) async throws {
        let userId = try await loadIdentityId()

        let dateString = formatter.string(from: date)

        let itemToDelete = PoopModel()
        itemToDelete?.userId = userId
        itemToDelete?.date = dateString

        objectMapper.remove(itemToDelete!).continueWith { task in
            if let error = task.error {
                print("❌ Delete error: \(error)")
//                completion(false)
            } else {
                print("✅ Deleted poop for \(dateString)")
//                completion(true)
            }
            return nil
        }
    }
}
