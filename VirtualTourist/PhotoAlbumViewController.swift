//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Neel Nishant on 28/01/18.
//  Copyright © 2018 Neel Nishant. All rights reserved.
//

import UIKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    let imageCache = NSCache<AnyObject, AnyObject>()
    @IBOutlet weak var collectionView: UICollectionView!
    var lat : String!
    var long : String!
    var imageNumber = 0
    var photosURLDictionary = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=d2eab41b196d9ba760b21e0b3004b48d&lat=\(lat!)&lon=\(long!)&extras=url_m&format=json&nojsoncallback=1"
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
                return
            }
            print("data: \(parsedResult)")
            guard let photos = parsedResult["photos"] else {
                print(error.debugDescription)
                return
            }
            let total = Int(photos["total"] as! String)!
            if total > 0 && total > 21 {
                self.imageNumber = 21
                }
            else {
                self.imageNumber = total
            }
            print(self.imageNumber)
            if let photo = photos["photo"] as? [[String: AnyObject]] {
                for x in 0..<self.imageNumber {
                    let element = photo[x] as? [String:AnyObject]
                    let urlS = element!["url_m"] as? String
                    self.photosURLDictionary.append(urlS!)
                }
            }
            
            performUIUpdatesOnMain({
                self.collectionView.reloadData()
            })
            }
        task.resume()
        // Do any additional setup after loading the view.
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("imageNumber: \(imageNumber)")
        return imageNumber
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        if let cacheImage = self.imageCache.object(forKey: self.photosURLDictionary[indexPath.row] as AnyObject){
            cell.photo.image = cacheImage as! UIImage
        }
        else {
            performUIUpdatesOnMain {
                let imageData = try? Data(contentsOf: URL(string: self.photosURLDictionary[indexPath.row])!)
                let image = UIImage(data: imageData!)
                cell.photo.image = image
                self.imageCache.setObject(image!, forKey: self.photosURLDictionary[indexPath.row] as AnyObject)
            }
            print("url: \(photosURLDictionary[indexPath.row])")
        }
        
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
