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

    @IBOutlet weak var mapview: MKMapView!
    
    var car_annotation: CarLocation!
    var current_location: CLLocationCoordinate2D!
    
    var locating = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        while locating {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                self.start_gps_location_triggering()
//            }
//        }
        self.start_gps_location_triggering()
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
        renderer.fillColor = UIColor.black.withAlphaComponent(0.15)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 1
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
    
    func start_gps_location_triggering() {
        let url = "/system/location"
        let data = ["name": server_info.device_name] as NSDictionary
        server_api.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            let coordinates = response.value(forKey: "data") as! NSDictionary
            let latitude = coordinates.value(forKey: "latitude") as! CLLocationDegrees
            let longitude = coordinates.value(forKey: "longitude") as! CLLocationDegrees
            if code == server_api._SUCCESS_REPONSE_CODE {
                DispatchQueue.main.async {
                    // Update UI
                    let distance:CLLocationDistance = 500
                    self.current_location = CLLocationCoordinate2DMake(latitude, longitude)
                    let region = MKCoordinateRegionMakeWithDistance(self.current_location, distance, distance)
                    self.mapview.setRegion(region, animated: true)
                    
                    self.car_annotation = CarLocation(coordinate: self.current_location)
                    self.addAnnotations()
                }
            } else {
                // Alert message
                let alert_title = "Error"
                let alert_message = "Could not get GPS location. Check connection..."
                app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
            }
        })
    }

    @IBAction func navigation_to_vehicle_action(_ sender: Any) {
        let url = "/system/location"
        let data = ["name": server_info.device_name] as NSDictionary
        server_api.send_request(url: url, data: data, method: "POST", completion: {(response: NSDictionary) -> () in
            let code = response.value(forKey: "code") as! Int
            let coordinates = response.value(forKey: "data") as! NSDictionary
            let latitude = coordinates.value(forKey: "latitude") as! CLLocationDegrees
            let longitude = coordinates.value(forKey: "longitude") as! CLLocationDegrees
            if code == server_api._SUCCESS_REPONSE_CODE {
                DispatchQueue.main.async {
                    // Update UI
                    let distance:CLLocationDistance = 500
                    self.current_location = CLLocationCoordinate2DMake(latitude, longitude)
                    let region = MKCoordinateRegionMakeWithDistance(self.current_location, distance, distance)
                    self.mapview.setRegion(region, animated: true)
                    
                    self.car_annotation = CarLocation(coordinate: self.current_location)
                    self.addAnnotations()
                    
                    let options = [
                        MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
                        MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
                    ]
                    let placemark = MKPlacemark(coordinate: self.current_location, addressDictionary: nil)
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = "My Vehicle: Current Location"
                    mapItem.openInMaps(launchOptions: options)
                }
            } else {
                // Alert message
                let alert_title = "Error"
                let alert_message = "Could not get GPS location. Check connection..."
                app_utils.showDefaultAlert(controller: self, title: alert_title, message: alert_message)
            }
        })
    }
}
