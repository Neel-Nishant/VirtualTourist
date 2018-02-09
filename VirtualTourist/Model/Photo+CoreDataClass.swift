//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Neel Nishant on 31/01/18.
//  Copyright © 2018 Neel Nishant. All rights reserved.
//
//
import UIKit
import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {

    convenience init(title: String, imageUrl: String, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context){
            self.init(entity: entity, insertInto: context)
            self.title = title
            self.imageUrl = imageUrl
        }
        else {
            fatalError("Unable to find Entity name")
        }
    }
    var image: UIImage? {
        if imageData != nil {
            return UIImage(data: imageData! as Data)
        }
        return nil
    }
}
