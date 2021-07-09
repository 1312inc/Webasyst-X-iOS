//
//  NetworkingManager.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 28.05.2021.
//

import Foundation

class NetworkingManager {
    /// Image upload request
    /// - Parameters:
    ///   - url: Url image
    ///   - completion: Short-circuiting after an image has been loaded
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    /// The method of loading an image
    /// - Parameters:
    ///   - imagePath: Url image
    ///   - completion: Closing performed after loading the image
    /// - Returns: Data format image
    internal func downloadImage(_ imagePath: String, completion: @escaping (Data) -> ()) {
        getData(from: URL(string: imagePath)!) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                guard let response = response as? HTTPURLResponse else { return }
                if response.statusCode != 200 {
                    completion(Data())
                } else {
                    completion(data)
                }
                
            }
        }
    }
}
