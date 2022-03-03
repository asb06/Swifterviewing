//
//  API.swift
//  Swifterviewing
//
//  Created by Tyler Thompson on 7/9/20.
//  Copyright © 2020 World Wide Technology Application Services. All rights reserved.
//

import Foundation
import UIKit

struct API {
    let baseURL = "https://jsonplaceholder.typicode.com"
    let photosEndpoint = "/photos" //returns photos and their album ID
    let albumsEndpoint = "/albums" //returns an album, but without photos
    
    var session: URLSession!
    var cache: NSCache<NSString, UIImage>!
    
    init() {
        session = URLSession.shared
        self.cache = NSCache()
    }
    
    func getAlbums(callback: @escaping (Result<[Album], AlbumError>) -> Void) {
        guard let url = URL(string: baseURL + photosEndpoint) else {
            callback(.failure(.badURL))
            return
        }
        let urlsession = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let resultData = data else { return }
            do {
                let decoder = JSONDecoder()
                let json = try decoder.decode([Album].self, from: resultData)
                print(json)
                callback(.success(json))
            } catch {
                callback(.failure(.emptyResponse))
                print(error)
            }
        }
        urlsession.resume()
    }
    func getImageForPath(imagePath: String, completionHandler: @escaping (UIImage) -> ()) {
        
        if let image = self.cache.object(forKey: imagePath as NSString)  {
            completionHandler(image)
        } else {
            let url: URL! = URL(string: imagePath)
            session.downloadTask(with: url, completionHandler: { (location, response, error) in
                if let data = try? Data(contentsOf: url) {
                    guard let image = UIImage(data: data) else {return}
                    self.cache.setObject(image, forKey: imagePath as NSString)
                    completionHandler(image)
                }
            }).resume()
        }
    }
}

extension API {
    enum AlbumError: Error {
        case badURL
        case emptyResponse
    }
}
