//
//  ViewController.swift
//  ranch
//
//  Created by Caleb Thomas on 1/12/19.
//  Copyright © 2019 Caleb Thomas. All rights reserved.
//

import UIKit

import Alamofire
import GoogleMaps
import SnapKit
import SwiftyJSON

class MapViewController: UIViewController, UIPickerViewDelegate,
  UIPickerViewDataSource {
  
  // UIPicker
  var pickerData: [String] = [String]()
  var currentParkIndex :Int = 0
  
  // Google Map System Components
  var mapView:GMSMapView!
  let locationDict = ["Yosemite": ["lat": 37.8651, "long": -119.5383],
                      "Yellowstone": ["lat": 44.4280, "long": -110.5885],
                      "Joshua Tree": ["lat": 34.016344, "long": -116.169257]]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Create a GMSCameraPosition that tells the map to display the
    let camera = GMSCameraPosition.camera(withLatitude: 37.8651, longitude: -119.5383, zoom: 14)
    mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
    view.addSubview(mapView)
    
    // Creates a marker in the center of the map.
    let marker = GMSMarker()
    marker.position = CLLocationCoordinate2D(latitude: 37.8651, longitude: -119.5383)
    marker.title = "Yosemite National Park"
    marker.snippet = "Yosemite"
    marker.map = mapView
    
    // Initialize Picker
    let parkPicker = UIPickerView()
    pickerData = ["Yosemite", "Yellowstone", "Joshua Tree"]
    
    parkPicker.delegate = self
    parkPicker.dataSource = self

    // handle picker layout
    self.view.addSubview(parkPicker)
    self.view.bringSubviewToFront(parkPicker)
    
    // add constraints to parkPicker
    parkPicker.snp.makeConstraints { (make) -> Void in
      make.top.equalTo(self.view).offset(10)
      make.left.equalTo(self.view).offset(20)
      make.right.equalTo(self.view).offset(-20)
    }
    
    // Add points from web server
    getTrashPoints()

  }
  
  //MARK: HTTP Requests
  func getTrashPoints() {
    AF.request("https://ramranch.appspot.com/").responseJSON { response in
      switch response.result {
      case .success(let value):
        let json = JSON(value)
        
        for (_,item):(String, JSON) in json {
          print(item)
          let marker = TrashMarker()
          marker.position = CLLocationCoordinate2D(latitude: item["location"]["latitude"].double!, longitude: item["location"]["longitude"].double!)
          marker.map = self.mapView
          
          // added to keep track of photo
          marker.clean = item["clean"].bool!
          marker.photoid = item["photo-id"].string!
        }
        
      case .failure(let error):
        print(error)
      }
    }
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
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if row != self.currentParkIndex {
      self.currentParkIndex = row
      
      // move camera to new location
      let coord = locationDict[pickerData[row]]
      print("New Location: \(coord)\n")
      
      let newLoc = GMSCameraPosition.camera(withLatitude: coord!["lat"]!, longitude: coord!["long"]!, zoom: 16)
      mapView.animate(to: newLoc)
    }
  }
}

