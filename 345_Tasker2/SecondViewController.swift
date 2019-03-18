//
//  SecondViewController.swift
//  Geotify
//
//  Created by Prakhar Rai on 6/11/17.
//

import UIKit
import GooglePlaces
import GoogleMaps
import GooglePlacePicker
import CoreLocation



class SecondViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager: CLLocationManager!
    var placePicker: GMSPlacePicker!
    var latitude: Double!
    var longitude: Double!
  
    var googleMapView: GMSMapView!
    
    @IBOutlet weak var mapViewContainer: UIView!
    
    @IBAction func showPlacePicker(_ sender: Any) {
      
      locationManager.stopUpdatingLocation()
      let center = CLLocationCoordinate2DMake(self.latitude, self.longitude)
      let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
      let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
      let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
      let config = GMSPlacePickerConfig(viewport: viewport)
      let placePicker = GMSPlacePicker(config: config)
      
      placePicker.pickPlace(callback: {(place, error) -> Void in
        if let error = error {
          print("Pick Place error: \(error.localizedDescription)")
          return
        }
        
        if let place = place {
          let coordinates = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
          let marker = GMSMarker(position: coordinates)
          marker.title = place.name
          marker.map = self.googleMapView
          self.googleMapView.animate(toLocation: coordinates)
        } else {
          print("No place was selected")
        }
      })
  }
  
    /*
    @IBAction func showPlacePicker(_ sender: Any) {
      // 1
      let center = CLLocationCoordinate2DMake(self.latitude, self.longitude)
      let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
      let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
      let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
      let config = GMSPlacePickerConfig(viewport: viewport)
      self.placePicker = GMSPlacePicker(config: config)
      
      // 2
      var error: NSError? = nil
      var gmsPlace: GMSPlace? = nil
      placePicker.pickPlace() {
        (gmsPlace, error) -> Void in
        
        if let error = error {
          print("Error occurred: \(error.localizedDescription)")
          return
        }
        // 3
        if let place = gmsPlace {
          let coordinates = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
          let marker = GMSMarker(position: coordinates)
          marker.title = place.name
          marker.map = self.googleMapView
          self.googleMapView.animate(toLocation: coordinates)
        } else {
          print("No place was selected")
        }
      }
    }
  
  */
  
    override func viewDidLoad() {
        super.viewDidLoad()
      /*
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
*/
  }
  
  
    override func viewDidAppear(_ animated: Bool) {
    
      super.viewDidAppear(animated)
      self.googleMapView = GMSMapView(frame: self.mapViewContainer.frame)
      self.googleMapView.animate(toZoom: 18.0)
      self.view.addSubview(googleMapView)
      determineMyCurrentLocation()
    
  }
  
    //MARK - Video Dude
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
    
      
  }
  
 
    func determineMyCurrentLocation() {
      locationManager = CLLocationManager()
      locationManager.delegate = self
      locationManager.requestAlwaysAuthorization()
    
      if CLLocationManager.locationServicesEnabled() {
        locationManager.startUpdatingLocation()
        print("STARTED")
      }
  }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
      func locationManager(_ manager:CLLocationManager,
                           didUpdateLocations locations: [CLLocation]){
      // 1
      let location:CLLocation = locations[0] as CLLocation
      manager.stopUpdatingLocation()
      //print("user latitude = \(location.coordinate.latitude)")
      //print("user longitude = \(location.coordinate.longitude)")
      self.latitude = location.coordinate.latitude
      self.longitude = location.coordinate.longitude
    
      // 2
      let coordinates = CLLocationCoordinate2DMake(self.latitude, self.longitude)
      //print(" COORDINATE :" + String(describing: coordinates))
      let marker = GMSMarker(position: coordinates)
      marker.title = "I am here"
      marker.map = self.googleMapView
      self.googleMapView.animate(toLocation: coordinates)
  }
  
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error){
    
      print("An error occurred while tracking location changes : \(error)")
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
