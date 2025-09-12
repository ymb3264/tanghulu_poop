//
//  StorageService.swift
//  tanghulu_poop
//
//  Created by Mohwa Yoon on 5/16/25.
//

import AWSDynamoDB

class PoopStorageService {
    let userId = "Tanghulu"
    
    func savePoop(for userId: String = "mobul", date: Date, size: Size) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let model = PoopModel()
        model?.userId = self.userId
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

    func loadPoop(for userId: String = "mobul", date: Date, completion: @escaping (Size?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)

        objectMapper.load(PoopModel.self, hashKey: self.userId, rangeKey: dateString).continueWith { task in
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
    
    func loadAllPoop(for userId: String = "mobul", completion: @escaping ([PoopInfo]) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()

        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "userId = :userId"
        queryExpression.expressionAttributeValues = [":userId": self.userId]

        objectMapper.query(PoopModel.self, expression: queryExpression).continueWith { task in
            if let error = task.error {
                print("❌ Query error: \(error)")
                completion([])
            } else if let results = task.result?.items as? [PoopModel] {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                let poopInfos: [PoopInfo] = results.compactMap { item in
                    guard
                        let dateString = item.date,
                        let date = formatter.date(from: dateString),
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
    func deletePoop(for userId: String = "mobul", date: Date) {
        let objectMapper = AWSDynamoDBObjectMapper.default()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)

        let itemToDelete = PoopModel()
        itemToDelete?.userId = self.userId
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
