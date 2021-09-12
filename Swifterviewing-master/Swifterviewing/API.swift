//
//  API.swift
//  Swifterviewing
//
//  Created by Tyler Thompson on 7/9/20.
//  Copyright © 2020 World Wide Technology Application Services. All rights reserved.
//

import Foundation
import UIKit
class API{
    let baseURL = "https://jsonplaceholder.typicode.com"
    let photosEndpoint = "/photos" //returns photos and their album ID
    let albumsEndpoint = "/albums" //returns an album, but without photos
    public init() {}

    
    func getAlbums(callback: @escaping((Result<[Album], AlbumError>) -> Void)) {
        let urlPath = "\(baseURL)\(photosEndpoint)"
        guard let url = URL(string: urlPath)
            else { callback(.failure(.internalError)); return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        
        call(with: request, completion: callback)

    }
    
    private func call<T: Codable>(with request: URLRequest,
                                  completion: @escaping((Result<[T], AlbumError>) -> Void)) {
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil
                else { completion(.failure(.serverError)); return }
            do {
                guard let data = data
                    else { completion(.failure(.serverError)); return }
                let object = try JSONDecoder().decode([T].self, from: data)
                completion(Result.success(object))
            } catch {
                completion(Result.failure(.parsingError))
            }
        }
        dataTask.resume()
    }
}

extension API {
    enum AlbumError: Error {
        case internalError
        case serverError
        case parsingError
    }
}



extension UIImageView {
    func loadImage(fromURL urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }

        let activityView = UIActivityIndicatorView(style: .medium)
        self.addSubview(activityView)
        activityView.frame = self.bounds
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityView.startAnimating()

        if let image = loadImageFromTempDirectory(url: url){
            DispatchQueue.main.async {
                activityView.stopAnimating()
                activityView.removeFromSuperview()
                self.image = image
            }
        }else{
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                DispatchQueue.main.async {
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                }

                if let data = data {
                    self.saveImageToTempDirectory(imagedata: data, url: url)
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }.resume()
        }
    }
    
    func loadImageFromTempDirectory(url: URL) -> UIImage? {
        var dirPath = FileManager.default.temporaryDirectory
        dirPath.appendPathComponent(url.lastPathComponent)
        let imagePath = dirPath.absoluteString
        return UIImage(contentsOfFile:imagePath)
    }
    
    func saveImageToTempDirectory(imagedata: Data, url: URL) {
        //        if let data = image.pngData() {}
        var dirPath = FileManager.default.temporaryDirectory
        dirPath.appendPathComponent(url.lastPathComponent)
        do {
            try imagedata.write(to: dirPath)
            print("Successfully saved image at path: \(dirPath)")
        } catch {
            print("Error saving image: \(error)")
        }
    }
    
}
