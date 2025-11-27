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
    let recommendCount: Int
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
    
    func addProduct(date: Date, productId: String, name: String) async throws {
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

        objectMapper.save(model!).continueWith { task in
            if let error = task.error {
                print("Add error: \(error)")
            } else {
                print("Added vote for \(model!.productId!)")
            }
            return nil
        }
    }
    
    func cancelVote(productId: String) async throws {
        let userId = try await AWSService.loadIdentityId()

        let itemToDelete = ProductVotesModel()
        itemToDelete?.userId = userId
        itemToDelete?.productId = productId

        objectMapper.remove(itemToDelete!).continueWith { task in
            if let error = task.error {
                print("❌ Delete error: \(error)")
//                completion(false)
            } else {
                print("✅ Deleted vote for \(productId)")
//                completion(true)
            }
            return nil
        }
    }
}
