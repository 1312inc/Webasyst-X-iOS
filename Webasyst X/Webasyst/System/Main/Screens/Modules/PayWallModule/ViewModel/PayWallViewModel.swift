//
//  PayWallViewModel.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 19.12.2022.
//

import Foundation
import RxSwift
import RxCocoa
import StoreKit
import Webasyst

struct Price {
    let introductoryPrice: String
    let priceLocale: String
    let price: NSDecimalNumber
}

//MARK: PayWallViewModel
protocol PayWallViewModelType {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output { get }
}

//MARK: PayWallViewModel
final class PayWallViewModel: PayWallViewModelType {

    fileprivate var webasyst = WebasystApp()

    struct Input {
       //...
    }
    
    let input: Input
    
    struct Output {
        var dataSource: BehaviorRelay<[String]>
        var products: BehaviorRelay<[SKProduct]>
        var result: PublishRelay<Swift.Result<String?, String>>
    }
    
    let output: Output
    
    private var disposeBag = DisposeBag()
            
    //MARK: Input Objects
    
    //MARK: Output Objects
    fileprivate var dataSource: BehaviorRelay<[String]>
    fileprivate let products = BehaviorRelay<[SKProduct]>(value: [])
    fileprivate let result = PublishRelay<Swift.Result<String?, String>>()
    
    init() {
        
        dataSource = .init(value: [NSLocalizedString("payWallCollectionEmployeeNumber1", comment: ""),
                      NSLocalizedString("payWallCollection1", comment: ""),
                      NSLocalizedString("payWallCollection2", comment: ""),
                      NSLocalizedString("payWallCollectionDiskNumber1", comment: ""),
                      NSLocalizedString("payWallCollectionHistoryNumber1", comment: ""),
                      NSLocalizedString("payWallCollection3", comment: "")])
        
        //Init input property
        self.input = Input(
            //...
        )

        //Init output property
        self.output = Output(
            dataSource: dataSource,
            products: products,
            result: result
        )
                
        self.products.accept(Purchases.standard.products)
        
    }
    
    public func update(_ compl: @escaping () -> ()) {
        webasyst.checkUserAuth(completion: { _ in
            compl()
        })
    }
    
    public func currentIsFree() -> Bool {
        webasyst.getUserInstall(.currentInstall)?.cloudPlanId?.contains("X-1312-TEAMWORK-FREE") ?? false
    }
    
    public func productFormatter(products: [SKProduct], compl: @escaping ([Price]) -> Void) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        let arr = products.map { product -> Price in
            numberFormatter.locale = product.priceLocale
            guard let priceLocale = numberFormatter.string(from: product.price) else { return .init(introductoryPrice: "", priceLocale: "", price: .zero) }
            if let introductoryPrice = product.introductoryPrice?.price,
               let introductoryPriceLocale = numberFormatter.string(from: introductoryPrice) {
                return .init(introductoryPrice: introductoryPriceLocale, priceLocale: priceLocale, price: product.price)
            } else {
                return .init(introductoryPrice: "", priceLocale: priceLocale, price: product.price)
            }
        }
        compl(arr)
    }
    
    public func extendLicense(type: Plan, date: String) {
        let plan = currentIsFree() ? type : .none
        webasyst.extendLicense(type: plan.rawValue, date: date, completion: { result in
            switch result {
            case .success:
                self.result.accept(.success(nil))
            case .failure(let error):
                self.result.accept(.failure(error))
            }
        })
    }
    
}
