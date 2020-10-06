//
//  NetworkManager.swift
//  ImageFilter
//
//  Created by Agil Madinali on 10/6/20.
//

import Foundation
import UIKit

class NetworkManager {
    
    static let shared = NetworkManager()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() { }

    func request(urlString: String, headers: [String: String]?, parameters: [String: String]?, completed: @escaping (Any?) -> Void) {
        
        guard var urlComponents = URLComponents(string: urlString) else { return }
        
        if let parameters = parameters {
            var elements: [URLQueryItem] = []
            
            for (key, value) in parameters {
                elements.append(URLQueryItem(name: key, value: value))
            }
            urlComponents.queryItems = elements
        }
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let headers = headers {
            request.allHTTPHeaderFields = headers
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil, let data = data else {
                completed(nil)
                return
            }
            do {
                let dataDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                completed(dataDict)
            } catch {
                print(error)
                completed(nil)
            }
        }.resume()
    }
    
    func downloadImage(with imageUrl: String, completed: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: imageUrl)
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }
        
        DispatchQueue.global().async {
            if let url = URL(string: imageUrl) {
                do {
                    let data = try Data(contentsOf: url)
                    let image = UIImage(data: data)
                    completed(image)
                } catch { print(error) }
                return
            } else {
                completed(nil)
                return
            }
        }
    }
}
