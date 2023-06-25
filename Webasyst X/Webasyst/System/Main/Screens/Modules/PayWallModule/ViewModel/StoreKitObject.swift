//
//  StoreKitObject.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 19.12.2022.
//

import StoreKit
import Foundation

class Purchases: NSObject {
    static let standard = Purchases()

    public let productIdentifiers = Set(["teamwork.dreamteam.monthly", "teamwork.dreamteam.quarterly", "teamwork.dreamteam.yearly","teamwork.dreamteamplus.monthly", "teamwork.dreamteamplus.quarterly", "teamwork.dreamteamplus.yearly"])

    fileprivate var productRequest: SKProductsRequest?
    var paymentCompletion: ((SKPaymentTransactionState) -> Void)?
    var restoreCompletion: ((Error?) -> Void)?
    var products: [SKProduct] = []
    
    public func initialize() {
        requestProducts()
    }

    fileprivate func requestProducts() {
        productRequest?.cancel()

        let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest.delegate = self
        productRequest.start()

        self.productRequest = productRequest
    }
    
    func purchase(product: SKProduct, completion: @escaping (SKPaymentTransactionState) -> Void) {
           if SKPaymentQueue.canMakePayments() {
               let payment = SKPayment(product: product)
               SKPaymentQueue.default().add(payment)
               paymentCompletion = completion
           } else {
               completion(.failed)
           }
   }
    
    func restoreCompletion(completion: @escaping (Error?) -> Void) {
        SKPaymentQueue.default().restoreCompletedTransactions()
        restoreCompletion = completion
    }
    
}

extension Purchases: SKProductsRequestDelegate {
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let restoreCompletion {
            restoreCompletion(error)
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if let restoreCompletion {
            restoreCompletion(nil)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load products with error:\n \(error)")
    }
    
    public func startObserving() {
        SKPaymentQueue.default().add(self)
    }
     
     
    public func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }
    
}
 
extension Purchases: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            if let paymentCompletion = paymentCompletion {
                paymentCompletion(transaction.transactionState)
            }
            switch transaction.transactionState {
            case .purchased, .failed:
                queue.finishTransaction(transaction)
            case .deferred, .purchasing, .restored: break
            @unknown default: break
            }
        }
    }
    
}
