//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by Neel Nishant on 29/01/18.
//  Copyright © 2018 Neel Nishant. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
