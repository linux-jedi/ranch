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
  
  let pickerData = ["Yosemite", "Yellowstone", "Joshua Tree"]
  
  override func loadView() {
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
    let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
    view = mapView
    
    // Creates a marker in the center of the map.
    let marker = GMSMarker()
    marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
    marker.title = "Sydney"
    marker.snippet = "Australia"
    marker.map = mapView
    
    // Initialize Picker
    let parkPicker = UIPickerView()
    parkPicker.delegate = self
    parkPicker.dataSource = self
    
    // handle picker layout
    self.view.addSubview(parkPicker)
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
}

