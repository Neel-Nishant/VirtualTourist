//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Neel Nishant on 02/02/18.
//  Copyright © 2018 Neel Nishant. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient : NSObject {
    func taskForGETMethod(latitude: String, longitude: String,currentPin: Pin, page: Int, completionHandler: @escaping(_ success: Bool, _ error: String?) -> Void) {
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=6cb4d842c14cd20597deccad8b534c8b&lat=\(latitude)&lon=\(longitude)&extras=url_m&per_page=18&page=\(page)&format=json&nojsoncallback=1"
        print(urlString)
        let urlRequest = URLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                print(error)
            }
            guard let data = data else {
                return
            }
            
            
            let parsedResult :[String: AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]
            }
            catch {
                completionHandler(false, "error parsing data")
                return
            }
//            print("data: \(parsedResult)")
            guard let images = parsedResult["photos"] else {
                print(error.debugDescription)
                return
            }
//            let total = Int(photos["total"] as! String)!
//            if total > 0 && total > 21 {
//                self.imageNumber = 21
//            }
//            else {
//                self.imageNumber = total
//            }
//            print(self.imageNumber)
            if let photoArray = images["photo"] as? [[String: AnyObject]] {
                for img in photoArray {
//                    let element = photo[x] as? [String:AnyObject]
                    let urlS = img["url_m"] as? String
                    let photo = Photo(context: CoreDataStack.sharedInstance().context)
                    photo.imageUrl = urlS!
                    photo.pin = currentPin
                    photo.title = "Hello"
//                    self.photosURLDictionary.append(urlS!)
                    CoreDataStack.sharedInstance().context.insert(photo)
                }
                do {
                    try CoreDataStack.sharedInstance().saveContext()
                }
                catch {
                    completionHandler(false, "error saving data")
                }
            }
            completionHandler(true, nil)
//            performUIUpdatesOnMain({
//                self.collectionView.reloadData()
//            })
        }
        task.resume()
    }
    
    func getImagesForCell(imageUrl: String, completionHandler: @escaping(_ image: UIImage)-> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            let imgData = try? Data(contentsOf: URL(string: imageUrl)!)
            let image = UIImage(data: imgData!)
            performUIUpdatesOnMain {
                completionHandler(image!)
            }
        }
        
    }
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}
