//
//  ImageManager.swift
//  Flickr
//
//  Created by Yu, Huiting on 3/16/18.
//  Copyright © 2018 Yu, Huiting. All rights reserved.
//

import Foundation


class FlickerManager {
    static let shared = FlickerManager()
    private let baseUrl: String = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&format=json&nojsoncallback=1"
    private var page = 1
    
    func requestImages(keyword: String, resetPage: Bool, completion: @escaping (([URL]?, Error?)->Void)) {
        if resetPage { page = 1 }
        else { page += 1}
        guard let url = URL(string: baseUrl+"&text=\(keyword)&page=\(page)") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            var urls: [URL]?, err: Error? = error
            defer {
                DispatchQueue.main.async {
                    completion(urls, err)
                }
            }
            guard let data = data else {
                return
            }
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            guard let photosJson = json["photos"]["photo"] as? [[String: Any]] else {
                return
            }
            print("JSON: \(photosJson)")
            urls = []
            err = nil
            for subjson in photosJson {
                if let id = subjson["id"] as? String, let secret=subjson["secret"] as? String, let server = subjson["server"] as? String, let farm=subjson["farm"] as? Int,
                    let imgUrl = URL(string: "http://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret).jpg") {
                    urls?.append(imgUrl)
                }
            }
        }.resume()
    }
}
