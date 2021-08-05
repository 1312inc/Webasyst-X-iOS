//
//  Shop module - ShopModel.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 26/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct OrderList: Decodable {
    let orders: [Orders]
}

struct Orders: Decodable {
    let id: String
    let stateId: StatusOrder
    let total: String
    let currency: String
    let shipping: String
    let params: ParamOrder
    let idEncoded: String
    
    private enum CodingKeys: String, CodingKey {
        case id, total, currency, params, shipping
        case stateId = "state_id"
        case idEncoded = "id_encoded"
    }
}

enum StatusOrder: Decodable {
    case new, shipped, completed, refuned
    case unknown(value: String)
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try? container.decode(String.self)
        switch status {
        case "new": self = .new
        case "shipped": self = .shipped
        case "completed": self = .completed
        case "refuned": self = .refuned
        default:
            self = .unknown(value: status ?? "unknown")
        }
    }
}

struct ItemsOrder: Decodable {
    let id: String
    let type: TypeItems?
    let skuCode: String
    let price: String
    let quantity: String
    
    private enum CodingKeys: String, CodingKey {
        case id, type, price, quantity
        case skuCode = "sku_code"
    }
}

enum TypeItems: Decodable {
    case product, service
    case unknown(value: String)
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try? container.decode(String.self)
        switch status {
        case "product": self = .product
        case "service": self = .service
        default:
            self = .unknown(value: status ?? "unknown")
        }
    }
}

struct ParamOrder: Decodable {
    let shippingId: String?
    let shipingAddressCountry: String?
    let shippingAddressCity: String?
    let shippingAddress: String?
    let shippingName : String?
    let shippingEstDelivery: String?
    let shippingCurrency: String?
    
    private enum CodingKeys: String, CodingKey {
        case shippingId = "shipping_id"
        case shipingAddressCountry = "shipping_address.country"
        case shippingAddressCity = "shipping_address.city"
        case shippingAddress = "shipping_address.street"
        case shippingName = "shipping_name"
        case shippingEstDelivery = "shipping_est_delivery"
        case shippingCurrency = "shipping_currency"
    }
}
