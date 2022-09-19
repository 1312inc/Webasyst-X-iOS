//
//  PhotoModel.swift
//  Webasyst X
//
//  Created by Леонид Лукашевич on 18.09.2022.
//

import Foundation

struct PhotoList: Decodable {
    let photos: [Photos]
}

struct Photos: Decodable {
    let id: String
    let name: String
    let ext: String
    let upload_datetime: String
    let image_url: String
    
    private enum CodingKeys: String, CodingKey {
        case id, name, ext, upload_datetime, image_url
    }
}
