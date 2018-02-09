//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Neel Nishant on 31/01/18.
//  Copyright © 2018 Neel Nishant. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {

    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext){
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: entity, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            }
        else {
            fatalError("Unable to find Entity name")
        }
    }
}
