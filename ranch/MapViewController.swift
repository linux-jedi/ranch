//
//  ViewController.swift
//  ranch
//
//  Created by Caleb Thomas on 1/12/19.
//  Copyright © 2019 Caleb Thomas. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, UIPickerViewDelegate,
  UIPickerViewDataSource {
  
  // UIPicker
  var pickerData: [String] = [String]()
  var currentParkIndex :Int = 0
  
  // Google Map System Components
  var mapView:GMSMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
    mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
    view.addSubview(mapView)
    
    // Creates a marker in the center of the map.
    let marker = GMSMarker()
    marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
    marker.title = "Sydney"
    marker.snippet = "Australia"
    marker.map = mapView
    
    // Initialize Picker
    let parkPicker = UIPickerView()
    pickerData = ["Yosemite", "Yellowstone", "Joshua Tree"]
    parkPicker.delegate = self
    parkPicker.dataSource = self

    // handle picker layout
    self.view.addSubview(parkPicker)
    self.view.bringSubviewToFront(parkPicker)
  }
  
  //MARK: UIPickerDelegate Mathods
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerData.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerData[row]
  }
  
//  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//    if row != self.currentParkIndex {
//      self.currentParkIndex = row
//      
//      // move camera to new location
//      print("New Location: \(pickerData[row])\n")
//      
//      
//    }
//  }
}

