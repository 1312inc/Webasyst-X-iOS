//
//  TemporaryStorage.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 04.10.2022.
//

import Foundation
import Cache

enum ThrowableError: Error {
    case withoutId
}

enum TypeOfStorage: String {
    case filteredCounts
    case milestonesList
    case projectsList
    case statusesList
    case tasksList
    case updatesList
    case teamList
    case concreteTask
}

class TemporaryStorage<WrappedKeyLog: Codable> {
    
    init() {
        try? storage?.removeExpiredObjects()
    }
    
}

extension TemporaryStorage {
    
    fileprivate var diskConfig: DiskConfig {
        DiskConfig(name: "TeamworkFloppy")
    }
    
    fileprivate var transformer: Transformer<[WrappedKeyLog]> {
        TransformerFactory.forCodable(ofType: [WrappedKeyLog].self)
    }
    
    fileprivate var memoryConfig: MemoryConfig {
        MemoryConfig()
    }
    
    fileprivate var storage: Storage<String, [WrappedKeyLog]>? {
        try? Storage<String, [WrappedKeyLog]>(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: transformer)
    }
    
    fileprivate var activeInstall: String {
        UserDefaults.standard.string(forKey: UserDefaults.activeSettingClientId) ?? ""
    }
    
    public func current(type: TypeOfStorage, taskCache: String = "") throws -> [WrappedKeyLog]? {
        do {
            if let storage = storage, !activeInstall.isEmpty {
                if case .tasksList = type {
                    return try storage.object(forKey: "\(taskCache)")
                } else {
                    return try storage.object(forKey: "\(activeInstall).\(type.rawValue)")
                }
            } else {
            throw ServerError.withoutInstalls
            }
        } catch {
            throw error
        }
    }
    
    public func remove() {
        
    }
    
    public func setObject(type: TypeOfStorage, object: [WrappedKeyLog], taskCache: String = "") {
        do {
        if case .tasksList = type {
            try storage?.setObject(object, forKey: "\(taskCache)")
        } else {
            let key = "\(activeInstall).\(type.rawValue)"
            try storage?.setObject(object, forKey: key)
        }
        } catch {
            print(error)
        }
    }
    
    public func removeAll() {
        try? storage?.removeAll()
    }
    
}
