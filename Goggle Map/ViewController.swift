//
//  ViewController.swift
//  Goggle Map
//
//  Created by Tipu Sultan on 4/12/25.


import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    var mapView: GMSMapView!
    var currentMarker: GMSMarker?
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Location Manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // Setup initial map camera
        let camera = GMSCameraPosition.camera(withLatitude: 23.8103, longitude: 90.4125, zoom: 14.0)
        mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
        mapView.delegate = self
        view.addSubview(mapView)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        print("📍 Current Location: Latitude: \(latitude), Longitude: \(longitude)")

        // Reverse Geocoding to get the place
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("❌ Reverse geocoding failed: \(error.localizedDescription)")
                return
            }

            if let placemark = placemarks?.first {
                let name = placemark.name ?? ""
                let locality = placemark.locality ?? ""
                let administrativeArea = placemark.administrativeArea ?? ""
                let country = placemark.country ?? ""

                let fullAddress = "\(name), \(locality), \(administrativeArea), \(country)"
                print("📌 Address: \(fullAddress)")

                // Update marker title
                self.currentMarker?.title = fullAddress
            }
        }

        // Set camera to user's current location
        let camera = GMSCameraPosition.camera(withLatitude: latitude,
                                              longitude: longitude, zoom: 14.0)
        mapView.animate(to: camera)

        // Drop a pin at current location if not already placed
        if currentMarker == nil {
            currentMarker = GMSMarker(position: location.coordinate)
            currentMarker?.title = "Your Location"
            currentMarker?.map = mapView
            currentMarker?.isDraggable = true
        }
    }



    // Handle any errors with location manager
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }

    // When the user taps on the map
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // Clear previous marker if any
        currentMarker?.map = nil

        // Add a new marker at tapped location
        currentMarker = GMSMarker(position: coordinate)
        currentMarker?.title = "Selected Location"
        currentMarker?.map = mapView
        currentMarker?.isDraggable = true

        // Print coordinates of the tapped location
        print("Tapped Location: Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
    }

    // When the user finishes dragging the marker
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        let newCoordinate = marker.position
        // Print the new location after dragging
        print("Dragged Location: Latitude: \(newCoordinate.latitude), Longitude: \(newCoordinate.longitude)")
    }
}
