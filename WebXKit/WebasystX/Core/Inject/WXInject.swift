//
//  WXInject.swift
//  WebasystX
//
//  Created by Administrator on 12.11.2020.
//

import Foundation

enum WXInjectionError: Error {
    case failedResloveInjactableValue
    case fialedCastInjactableClass
}

enum WXInjectionType {
    case singelton
    case transient
}

protocol WXInjectable {
    
    static var injecatableName: String { get set }
    static var injecatableClass: AnyClass { get set }
    
}

protocol WXDependecyContainer {
    
    static func acquireContainer() -> WXDependecyContainer
    func registrate<Injectable: WXInjectable>(injectable: Injectable, type: WXInjectionType)
    func reslove<Injectable: WXInjectable>(name: String) throws -> Injectable
    
}


@propertyWrapper
struct WXInjection<Injectable: WXInjectable, Container: WXDependecyContainer> {
    
    private var injectableValue: Injectable!
    public var container: Container?
    public var name: String?
    
    public init() {
        self.container = (Container.acquireContainer() as! Container)
        self.name = Injectable.injecatableName
    }
    
 
    public var wrappedValue: Injectable {
        mutating get {
            guard let value = self.injectableValue else {
                self.injectableValue = try! container?.reslove(name: name!)
                return injectableValue
            }
            
            return value
        } set {
            injectableValue = newValue
        }
    }
    
    public var projectedValue: WXInjection<Injectable, Container> {
            get { return self }
            mutating set { self = newValue }
    }
    
}
