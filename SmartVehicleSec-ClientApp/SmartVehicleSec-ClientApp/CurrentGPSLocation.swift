//
//  CurrentGPSLocation.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 8/1/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import Foundation
import MapKit

class CarLocation: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.title = "My Vehicle"
    }
}
