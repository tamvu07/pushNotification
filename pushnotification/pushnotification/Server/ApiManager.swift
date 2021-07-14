//
//  ApiManager.swift
//  pushnotification
//
//  Created by Vu Minh Tam on 7/7/21.
//

import Foundation
import Alamofire

private let allowedDiskSize = 100 * 1024 * 1024
var cache: URLCache = {
    return URLCache(memoryCapacity: 0, diskCapacity: allowedDiskSize, diskPath: "gifCache")
}()

class MediageApiManager {
    
    static let shareInstance = MediageApiManager()
    



typealias DownloadCompletionHandler = (Result<Data,Error>) -> ()

private func createAndRetrieveURLSession() -> URLSession {
    let sessionConfiguration = URLSessionConfiguration.default
    sessionConfiguration.requestCachePolicy = .returnCacheDataElseLoad
    sessionConfiguration.urlCache = cache
    return URLSession(configuration: sessionConfiguration)
}

 func downloadContent(fromUrlString: String, completionHandler: @escaping DownloadCompletionHandler) {

    guard let downloadUrl = URL(string: fromUrlString) else { return }
    let urlRequest = URLRequest(url: downloadUrl)
    // First try to fetching cached data if exist
    if let cachedData = cache.cachedResponse(for: urlRequest) {
        print("Cached data in bytes:", cachedData.data)
        completionHandler(.success(cachedData.data))
        

    } else {
        // No cached data, download content than cache the data
        createAndRetrieveURLSession().dataTask(with: urlRequest) { (data, response, error) in

            if let error = error {
                completionHandler(.failure(error))
            } else {
                let cachedData = CachedURLResponse(response: response!, data: data!)
                cache.storeCachedResponse(cachedData, for: urlRequest)
                completionHandler(.success(data!))
            }
        }.resume()
    }
}
    
    func clearCache(){
        let cacheURL =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory( at: cacheURL, includingPropertiesForKeys: nil, options: [])
            for file in directoryContents {
                do {
                    try fileManager.removeItem(at: file)
                }
                catch let error as NSError {
                    debugPrint("Ooops! Something went wrong: \(error)")
                }

            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func clearContents(_ url:URL) {

        do {

            let contents = try FileManager.default.contentsOfDirectory(atPath: url.path)

            print("before  \(contents)")

            let urls = contents.map { URL(string:"\(url.appendingPathComponent("\($0)"))")! }

            urls.forEach {  try? FileManager.default.removeItem(at: $0) }

            let con = try FileManager.default.contentsOfDirectory(atPath: url.path)

            print("after \(con)")

        }
        catch {

            print(error)

        }

     }
}

//
// ...cache image start

let imageCache = NSCache<AnyObject, AnyObject>()

class ImageLoader: UIImageView {

var imageURL: URL?

let activityIndicator = UIActivityIndicatorView()

func loadImageWithUrl(_ url: URL) {

// setup activityIndicator...
activityIndicator.color = .darkGray

addSubview(activityIndicator)
activityIndicator.translatesAutoresizingMaskIntoConstraints = false
activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

imageURL = url

image = nil
activityIndicator.startAnimating()

// retrieves image if already available in cache
if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? UIImage {

    self.image = imageFromCache
    activityIndicator.stopAnimating()
    return
}

// image does not available in cache.. so retrieving it from url...
    URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
        
        if error != nil {
            print(error as Any)
            DispatchQueue.main.async(execute: {
                self.activityIndicator.stopAnimating()
            })
            return
        }
        
        DispatchQueue.main.async(execute: {
            
            if let unwrappedData = data, let imageToCache = UIImage(data: unwrappedData) {
                
                if self.imageURL == url {
                    self.image = imageToCache
                }
                
                imageCache.setObject(imageToCache, forKey: url as AnyObject)
            }
            self.activityIndicator.stopAnimating()
        })
    }).resume()
  }
}
// ...cache image end

