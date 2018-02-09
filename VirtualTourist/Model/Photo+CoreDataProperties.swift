//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Neel Nishant on 31/01/18.
//  Copyright © 2018 Neel Nishant. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var imageUrl: String?
    @NSManaged public var title: String?
    @NSManaged public var pin: Pin?

}
