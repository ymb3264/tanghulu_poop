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
