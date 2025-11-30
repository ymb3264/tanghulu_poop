//
//  PoopProductsService.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 11/27/25.
//

import AWSDynamoDB

struct PoopProduct: Codable, Equatable {
    let productId: String
    let createdBy: String
    let name: String
    let imageUrl: String?
    var recommendCount: Int
}

struct UserProductVote: Codable, Equatable {
    let productId: String
}

class PoopProductsService {
    private let formatter: ISO8601DateFormatter
    private let objectMapper = AWSDynamoDBObjectMapper.default()
    
    init() {
        let f = ISO8601DateFormatter()
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.formatOptions = [.withInternetDateTime] // 필요 시 .withFractionalSeconds 추가
        self.formatter = f
    }
    
    func loadProducts(completion: @escaping ([PoopProduct]) -> Void) async throws {
        let scanExpression = AWSDynamoDBScanExpression()
        
        scanExpression.filterExpression = "#cb = :admin"
        scanExpression.expressionAttributeNames = [
            "#cb": "createdBy"
        ]
        scanExpression.expressionAttributeValues = [
            ":admin": "admin"
        ]
        
        objectMapper.scan(ProductsModel.self, expression: scanExpression).continueWith { task in
            if let error = task.error {
                print("❌ Scan error: \(error)")
                completion([])
            } else if let results = (task.result?.items as? [ProductsModel]) {
                let products = results.compactMap { item -> PoopProduct? in
                    guard
                        let productId = item.productId,
                        let createdBy = item.createdBy,
                        let name = item.name,
                        let recommendCount = item.recommendCount
                    else {
                        return nil
                    }
                    
                    return PoopProduct(
                        productId: productId,
                        createdBy: createdBy,
                        name: name,
                        imageUrl: item.imageUrl,
                        recommendCount: recommendCount.intValue
                    )
                }
                
                completion(products)
            } else {
                completion([])
            }
            
            return nil
        }
    }
    
    func addProduct(date: Date, productId: String, name: String, completion: @escaping () -> Void = {}) async throws {
        let userId = try await AWSService.loadIdentityId()

        let model = ProductsModel()
        model?.productId = productId
        model?.createdAt = formatter.string(from: date)
        model?.createdBy = userId
        model?.name = name
        model?.recommendCount = 0

        objectMapper.save(model!).continueWith { task in
            if let error = task.error {
                print("Save error: \(error)")
            } else {
                print("Saved product for \(model!.name!)")
                completion()
            }
            return nil
        }
    }

    
    func loadUserVotes(completion: @escaping ([UserProductVote]) -> Void) async throws {
        let userId = try await AWSService.loadIdentityId()

        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "userId = :userId"
        queryExpression.expressionAttributeValues = [":userId": userId]

        objectMapper.query(ProductVotesModel.self, expression: queryExpression).continueWith { task in
            if let error = task.error {
                print("❌ Query error: \(error)")
                completion([])
            } else if let results = task.result?.items as? [ProductVotesModel] {
                let votes: [UserProductVote] = results.compactMap { item in
                    guard
                        let productId = item.productId
                    else {
                        return nil
                    }
                    return UserProductVote(productId: productId)
                }

                completion(votes)
            } else {
                completion([])
            }
            
            return nil
        }
    }
    
    func addVote(date: Date, productId: String) async throws {
        let userId = try await AWSService.loadIdentityId()

        let model = ProductVotesModel()
        model?.userId = userId
        model?.productId = productId
        model?.createdAt = formatter.string(from: date)
        
        try await saveAsync(model!)
        
        try await updateRecommendCount(productId: productId, delta: 1)
        
        print("✅ Added vote + increased count")

//        objectMapper.save(model!).continueWith { task in
//            if let error = task.error {
//                print("Add error: \(error)")
//            } else {
//                print("Added vote for \(model!.productId!)")
//            }
//            return nil
//        }
    }
    
    func cancelVote(productId: String) async throws {
        let userId = try await AWSService.loadIdentityId()

        let itemToDelete = ProductVotesModel()
        itemToDelete?.userId = userId
        itemToDelete?.productId = productId

        try await removeAsync(itemToDelete!)
        
        try await updateRecommendCount(productId: productId, delta: -1)
        
        print("✅ Deleted vote + decreased count")
        
//        objectMapper.remove(itemToDelete!).continueWith { task in
//            if let error = task.error {
//                print("❌ Delete error: \(error)")
////                completion(false)
//            } else {
//                print("✅ Deleted vote for \(productId)")
////                completion(true)
//            }
//            return nil
//        }
    }
    
    // “카운트 +1/-1” 같은 **원자적 증가(동시성 안전)**는 objectMapper가 직접 지원을 잘 안 해서, 그 경우엔 low-level updateItem이 더 적합. - by gpt
    func updateRecommendCount(productId: String, delta: Int) async throws {
        let update = AWSDynamoDBUpdateItemInput()!
        update.tableName = "PoopProducts"
        
        let keyValue = AWSDynamoDBAttributeValue()
        keyValue?.s = productId

        update.key = [
            "productId": keyValue!
        ]

        update.updateExpression = "SET recommendCount = if_not_exists(recommendCount, :zero) + :delta"
        
        let deltaValue = AWSDynamoDBAttributeValue()
        deltaValue?.n = "\(delta)"
        
        update.expressionAttributeValues = [
            ":delta": deltaValue!,
            ":zero": {
                let v = AWSDynamoDBAttributeValue()
                v?.n = "0"
                return v!
            }()
        ]

        // recommendCount 0 아래로 못내려가게 방지
        if delta < 0 {
            update.conditionExpression = "recommendCount >= :absDelta"
            
            let absDeltaValue = AWSDynamoDBAttributeValue()
            absDeltaValue?.n = "\(-delta)"
            
            update.expressionAttributeValues?[":absDelta"] = absDeltaValue!
        }
        
        _ = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            AWSDynamoDB.default().updateItem(update).continueWith { task in
                if let error = task.error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume(returning: ())
                }
                return nil
            }
        }
    }
    
    // objectMapper.save를 async/await로 감싸는 헬퍼
    private func saveAsync(_ model: AWSDynamoDBObjectModel & AWSDynamoDBModeling) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            objectMapper.save(model).continueWith { task in
                if let error = task.error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume(returning: ())
                }
                return nil
            }
        }
    }
    
    // objectMapper.remove를 async/await로 감싸는 헬퍼
    private func removeAsync(_ model: AWSDynamoDBObjectModel & AWSDynamoDBModeling) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            objectMapper.remove(model).continueWith { task in
                if let error = task.error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume(returning: ())
                }
                return nil
            }
        }
    }
}
