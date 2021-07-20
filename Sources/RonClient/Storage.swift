//
//  Storage.swift
//  
//
//  Created by Lau Chun Kai on 16/7/2021.
//

import Foundation

public protocol Storage {
    func merge(key: String,
               reduce: @escaping (_ prev: String?) -> String?,
               completion: @escaping (String?) -> Void)
    func set(key: String,
             value: String,
             completion: @escaping () -> Void)
    func get(key: String,
             completion: @escaping (String?) -> Void)
    func multiGet(keys: Set<String>,
                  completion: @escaping ([String : String?]) -> Void)
    func remove(key: String,
                completion: @escaping () -> Void)
    func keys(completion: @escaping (Set<String>) -> Void)
}

public class InMemory : Storage {
    public internal(set) var storage: [String : String]
    public init(storage: [String : String] = [:]) {
        self.storage = storage
    }
}

public extension InMemory {
    func merge(key: String,
               reduce: @escaping (String?) -> String?,
               completion: @escaping (String?) -> Void) {
        let value = reduce(storage[key])
        storage[key] = reduce(storage[key])
        completion(value)
    }
    
    func set(key: String,
             value: String,
             completion: @escaping () -> Void) {
        storage[key] = value
        completion()
    }
    
    func get(key: String,
             completion: @escaping (String?) -> Void) {
        completion(storage[key])
    }
    
    func multiGet(keys: Set<String>,
                  completion: @escaping ([String : String?]) -> Void) {
        let notFoundKeys = keys.subtracting(storage.keys)
        let notFoundDict = Dictionary(
            uniqueKeysWithValues:
                zip(
                    notFoundKeys,
                    [String?](
                        repeating: nil,
                        count: notFoundKeys.count
                    )
                )
        )
        let result = notFoundDict
            .merging(
                storage.filter { key, _ in keys.contains(key) }
            ) { a, b in a }
        completion(result)
    }
    
    func remove(key: String,
                completion: @escaping () -> Void) {
        storage[key] = nil
        completion()
    }
    
    func keys(completion: @escaping (Set<String>) -> Void) {
        completion(Set(storage.keys))
    }
}
