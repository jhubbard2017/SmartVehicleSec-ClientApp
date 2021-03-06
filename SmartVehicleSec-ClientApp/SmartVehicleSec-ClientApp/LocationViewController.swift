//
//  LocationViewController.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 8/1/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController, MKMapViewDelegate {
    /* This is the class for the location view controller
     
     In this class, we periodically retrieve the gps coordinates of the security system and pin it to the map
     When the user wants to find their vehicle, we navigate to the Maps plugin for Mapkit passing in the current
     coordinates...
     */

    @IBOutlet weak var mapview: MKMapView!
    
    var car_annotation: CarLocation!
    var current_location: CLLocationCoordinate2D!
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        self.timer = Timer.scheduledTimer(timeInterval: 1.5, target: self,
                                          selector: #selector(self.get_gps_location),
                                          userInfo: nil, repeats: true)
        self.timer.fire()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Stop the background task when user navigates to new view controller
        print("Stopped getting location")
        self.timer.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addAnnotations() {
        self.mapview?.delegate = self
        self.mapview?.addAnnotation(self.car_annotation)
        
        let overlay = MKCircle(center: self.current_location, radius: 100)
        self.mapview.add(overlay)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        return renderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        } else {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            let image = UIImage(named: "car")
            let size = CGSize(width: 50, height: 50)
            UIGraphicsBeginImageContext(size)
            image!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            annotationView.image = resizedImage
            return annotationView
        }
    }
    
    func get_gps_location() {
        api.get_location(email: auth_info.email) { error, location in
            DispatchQueue.main.async {
                if (error == nil) {
                    let latitude = location?.value(forKey: "latitude") as! CLLocationDegrees
                    let longitude = location?.value(forKey: "longitude") as! CLLocationDegrees
                    let distance:CLLocationDistance = 500
                    self.current_location = CLLocationCoordinate2DMake(latitude, longitude)
                    let region = MKCoordinateRegionMakeWithDistance(self.current_location, distance, distance)
                    self.mapview.setRegion(region, animated: true)
                    self.car_annotation = CarLocation(coordinate: self.current_location)
                    self.addAnnotations()
                    print("Got location")
                } else {
                    // let title = "Error (\(String(describing: error?.code)))"
                    // let message = error?.domain
                    // app_utils.showDefaultAlert(controller: self, title: title, message: message!)
                    // self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    @IBAction func navigation_to_vehicle_action(_ sender: Any) {
        print("Stopped getting location")
        self.timer.invalidate()
        let distance:CLLocationDistance = 500
        let region = MKCoordinateRegionMakeWithDistance(self.current_location, distance, distance)
        
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
        ]
        let placemark = MKPlacemark(coordinate: self.current_location, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "My Vehicle"
        mapItem.openInMaps(launchOptions: options)
    }
}
