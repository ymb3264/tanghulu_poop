//
//  PoopModel.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 5/16/25.
//

import AWSDynamoDB

class PoopModel: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    @objc var userId: String?
    @objc var date: String?
    @objc var size: String?
    @objc var productId: String?
    @objc var productName: String?

    class func dynamoDBTableName() -> String {
        return "TanghuluPoop"
    }

    class func hashKeyAttribute() -> String {
        return "userId"
    }

    class func rangeKeyAttribute() -> String {
        return "date"
    }
}

class ProductsModel: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    @objc var productId: String?
    @objc var createdAt: String?
    @objc var createdBy: String?
    @objc var name: String?
    @objc var imageUrl: String?
    @objc var recommendCount: NSNumber?

    class func dynamoDBTableName() -> String {
        return "PoopProducts"
    }

    class func hashKeyAttribute() -> String {
        return "productId"
    }
}

class ProductVotesModel: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    @objc var userId: String?
    @objc var productId: String?
    @objc var createdAt: String?

    class func dynamoDBTableName() -> String {
        return "PoopProductVotes"
    }

    class func hashKeyAttribute() -> String {
        return "userId"
    }

    class func rangeKeyAttribute() -> String {
        return "productId"
    }
}
