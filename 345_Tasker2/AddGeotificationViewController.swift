

import UIKit
import MapKit

protocol AddGeotificationsViewControllerDelegate {
  func addGeotificationViewController(controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D,
    radius: Double, identifier: String, note: String, eventType: EventType)
}

class AddGeotificationViewController: UITableViewController, UISearchBarDelegate, UITextFieldDelegate {
  
  
  @IBOutlet var addButton: UIBarButtonItem!
  @IBOutlet var zoomButton: UIBarButtonItem!
  @IBOutlet weak var eventTypeSegmentedControl: UISegmentedControl!

  @IBOutlet weak var radiusTextField: UITextField!
  @IBOutlet weak var noteTextField: UITextField!
  @IBOutlet weak var mapView: MKMapView!
    
  // Variables - Custom
    
  @IBOutlet weak var showSearchBar: UIBarButtonItem!
    
  @IBAction func showSearchBar(_ sender: Any) {
    
    searchController = UISearchController(searchResultsController: nil)
    searchController.hidesNavigationBarDuringPresentation = false
    self.searchController.searchBar.delegate = self
    present(searchController, animated: true, completion: nil)
    
    }
  var searchController:UISearchController!
  var annotation:MKAnnotation!
  var localSearchRequest:MKLocalSearchRequest!
  var localSearch:MKLocalSearch!
  var localSearchResponse:MKLocalSearchResponse!
  var error:NSError!
  var pointAnnotation:MKPointAnnotation!
  var pinAnnotationView:MKPinAnnotationView!
  // End

  var delegate: AddGeotificationsViewControllerDelegate?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.rightBarButtonItems = [addButton, zoomButton, showSearchBar]
    addButton.isEnabled = false
    
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    self.view.endEditing(true)
    
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    textField.resignFirstResponder()
    
    return true
    
  }

  @IBAction func textFieldEditingChanged(sender: UITextField) {
    addButton.isEnabled = !radiusTextField.text!.isEmpty && !noteTextField.text!.isEmpty
  }

  @IBAction func onCancel(sender: AnyObject) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction private func onAdd(sender: AnyObject) {
    let coordinate = mapView.centerCoordinate
    let radius = Double(radiusTextField.text!) ?? 0
    let identifier = NSUUID().uuidString
    let note = noteTextField.text
    let eventType: EventType = (eventTypeSegmentedControl.selectedSegmentIndex == 0) ? .onEntry : .onExit
    delegate?.addGeotificationViewController(controller: self, didAddCoordinate: coordinate, radius: radius, identifier: identifier, note: note!, eventType: eventType)

    /*
    let myArray = UserDefaults.standard.object(forKey: "noteArray") as? NSArray
    
    if (myArray != nil){
      
      var noteArray:NSMutableArray = []
      noteArray = myArray as! NSMutableArray
      noteArray.addObjects(from: [noteTextField.text!])
      UserDefaults.standard.set(noteArray, forKey: "noteArray")
      print()
      print("IN IF STATEMENT")
      print(noteArray)
      print()
    }else {
      
      var noteArray: NSMutableArray = []
      noteArray.addObjects(from: [noteTextField.text!])
      UserDefaults.standard.set(noteArray, forKey: "noteArray")
      print()
      print("IN ELSE STATEMENT")
      print(noteArray)
      print()
    }
  */
  }

  @IBAction private func onZoomToCurrentLocation(sender: AnyObject) {
    mapView.zoomToUserLocation()
  
  }
  
  //Search - Function 
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
    //1
    searchBar.resignFirstResponder()
    dismiss(animated: true, completion: nil)
    if self.mapView.annotations.count != 0{
      annotation = self.mapView.annotations[0]
      self.mapView.removeAnnotation(annotation)
    }
    //2
    localSearchRequest = MKLocalSearchRequest()
    localSearchRequest.naturalLanguageQuery = searchBar.text
    localSearch = MKLocalSearch(request: localSearchRequest)
    localSearch.start { (localSearchResponse, error) -> Void in
      
      if localSearchResponse == nil{
        let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        return
      }
      //3
      //Try zoom
      let span = MKCoordinateSpan(latitudeDelta: 0.0001, longitudeDelta: 0.0001)
      let coor = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
      let region = MKCoordinateRegion(center: coor, span: span)
      self.mapView.setRegion(region, animated: true)
      //End Zoom
      
      self.pointAnnotation = MKPointAnnotation()
      self.pointAnnotation.title = searchBar.text
      self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
      
      
      self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
      self.mapView.centerCoordinate = self.pointAnnotation.coordinate
      self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
    }
  }
}
