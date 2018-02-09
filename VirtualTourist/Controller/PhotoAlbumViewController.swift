//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Neel Nishant on 28/01/18.
//  Copyright © 2018 Neel Nishant. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
//    let imageCache = NSCache<AnyObject, AnyObject>()
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionLabel: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImageLabel: UILabel!
    var lat : String!
    var long : String!
    var imageNumber = 0
    var currentPin: Pin?
    var photosURLDictionary = [String]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    var selectedIndexPaths = [IndexPath]()
    lazy var fetchedResultsController: NSFetchedResultsController<Photo> = { () ->
        NSFetchedResultsController<Photo> in
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.sortDescriptors = []
        
        let predicate = NSPredicate(format: "pin = %@", argumentArray: [currentPin])
        fr.predicate = predicate
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: CoreDataStack.sharedInstance().context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController as! NSFetchedResultsController<Photo>
        
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
//        print("lat:\(lat) long: \(long) pin: \(currentPin)")
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        setNoImagesLabel()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        flickrApiCall()
        collectionView.reloadData()
        setNoImagesLabel()
    }
    
    func setNewCollectionLabelText() {
        if selectedIndexPaths.count > 0 {
            newCollectionLabel.title = "Remove Selected Photos"
        }
        else {
            newCollectionLabel.title = "New Collection"
        }
    }
    func setNoImagesLabel () {
        if currentPin?.photos?.count == 0 {
            noImageLabel.isHidden = false
        }
        else {
            noImageLabel.isHidden = true
        }
    }
    func deletePhotos() {
        
        var photosToBeDeleted = [Photo]()
        if selectedIndexPaths.isEmpty {
            for photo in (currentPin?.photos)! {
                CoreDataStack.sharedInstance().context.delete(photo as! NSManagedObject)
            }
        }
        for index in selectedIndexPaths {
            photosToBeDeleted.append(fetchedResultsController.object(at: index))
        }
        for photo in photosToBeDeleted {
            CoreDataStack.sharedInstance().context.delete(photo)
        }
        selectedIndexPaths = [IndexPath]()
        newCollectionLabel.title = "New Collection"
        
        
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects // photos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
       cell.activityIndicator.hidesWhenStopped = true
        performUIUpdatesOnMain {
            cell.activityIndicator.startAnimating()
        }
        
        let photo = self.fetchedResultsController.object(at: indexPath)
        
        if photo.imageData != nil{
            print("Image data exists")
            performUIUpdatesOnMain {
                cell.photo.image = photo.image
                cell.activityIndicator.stopAnimating()
            }
        }
        else {
            print("Image data doesn't exist")
            FlickrClient.sharedInstance().getImagesForCell(imageUrl: photo.imageUrl!, completionHandler: { (image) in
                performUIUpdatesOnMain {
                    photo.imageData = UIImagePNGRepresentation(image) as! NSData
                    do {
                        try CoreDataStack.sharedInstance().saveContext()
                    }
                    catch{
                        print("errrrr")
                    }
                    cell.photo.image = image
                    cell.activityIndicator.stopAnimating()
                }
            })
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoAlbumCollectionViewCell
        if let index = selectedIndexPaths.index(of: indexPath) {
            
            cell.photo.alpha = 1.0
            selectedIndexPaths.remove(at: index)
        }
        else {
            selectedIndexPaths.append(indexPath)
            cell.photo.alpha = 0.3
        }
        setNewCollectionLabelText()
    }
    
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
  
    @IBAction func newCollectionAndDeleteButton(_ sender: Any) {
        if selectedIndexPaths.isEmpty {
            
            self.deletePhotos()
            print("selecindexcount: \(selectedIndexPaths.count)")
            FlickrClient.sharedInstance().taskForGETMethod(latitude: lat, longitude: long, currentPin: currentPin!, page: Int(arc4random() % 20), completionHandler: { (success, error) in
                if success {
                    performUIUpdatesOnMain {
                        self.collectionView.reloadData()
                        self.setNoImagesLabel()
                    }
                }
                if error != nil {
                    print("Could not get photos")
                }
                
            })
            
        }
        else {
            self.deletePhotos()
            collectionView.performBatchUpdates({
                
            }, completion: { (completed) in
                performUIUpdatesOnMain {
                    do {
                        try CoreDataStack.sharedInstance().saveContext()
                    }
                    catch {
                        print("error deleting photos")
                    }
                }
            })
//            do {
//                try CoreDataStack.sharedInstance().saveContext()
//            }
//            catch {
//                print("error deleting photos")
//            }
            selectedIndexPaths.removeAll()
            selectedIndexPaths = [IndexPath]()
            collectionView.reloadData()
        }
    }
    
}
