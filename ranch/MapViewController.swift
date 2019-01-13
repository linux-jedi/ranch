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
import SDWebImage
import SnapKit
import SwiftyJSON

class MapViewController: UIViewController,
  UIPickerViewDelegate, UIPickerViewDataSource,
  GMSMapViewDelegate {
  
  // UIPicker
  var pickerData: [String] = [String]()
  var currentParkIndex :Int = 0
  
  // Google Map System Components
  var mapView:GMSMapView!
  let locationDict = ["Yosemite": ["lat": 37.8651, "long": -119.5383],
                      "Yellowstone": ["lat": 44.4280, "long": -110.5885],
                      "Joshua Tree": ["lat": 34.016344, "long": -116.169257],
                      "UCSB":["lat": 34.411713 , "long": -119.846978]]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Create a GMSCameraPosition that tells the map to display the
    let camera = GMSCameraPosition.camera(withLatitude: 37.8651, longitude: -119.5383, zoom: 14)
    mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
    mapView.delegate = self
    view.addSubview(mapView)
    
    // Creates a marker in the center of the map.
    let marker = TrashMarker()
    marker.position = CLLocationCoordinate2D(latitude: 37.8651, longitude: -119.5383)
    marker.title = "Yosemite National Park"
    marker.snippet = "Yosemite"
    marker.map = mapView
    
    marker.photoid = "MEaa81351200b749a9ce395148588b3853"
    marker.clean = false
    
    // Initialize Picker
    let parkPicker = UIPickerView()
    pickerData = ["Yosemite", "Yellowstone", "Joshua Tree", "UCSB"]
    
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
      
      mapView.clear()
      getTrashPoints()
      
      let newLoc = GMSCameraPosition.camera(withLatitude: coord!["lat"]!, longitude: coord!["long"]!, zoom: 16)
      mapView.animate(to: newLoc)
    }
  }
  
  //MARK: GMSMapViewDelegate actions
  
  // tap marker for photo to appear
  func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
    marker.tracksInfoWindowChanges = true
    
    let trashMarker = marker as! TrashMarker
    print("photo id: \(trashMarker.photoid)\n")
    
    var imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
    
    // ImageView: rounded corners
    imageView.layer.cornerRadius = 15.0
    imageView.clipsToBounds = true
    
    // Download image
    imageView.sd_setImage(with: URL(string: "https://storage.googleapis.com/ramranch-images/\(trashMarker.photoid)"), placeholderImage:nil, completed: { (image, error, cacheType, url) -> Void in
      if ((error) != nil) {
        // set the placeholder image here
        imageView.image = UIImage(named: "defaultImage")
      } else {
        // success ... use the image
        imageView.image = image
      }
    })
    
    return imageView
  }
  
  // long press to delete marker and photo
  func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) -> Void {
    let alert = UIAlertController(title: "Mark as Clean?", message: "WARNING: When marked as Clean, object will be removed from the map.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: NSLocalizedString("Clean", comment: "Default action"), style: .cancel, handler: { _ in
      // remove marker
      marker.map = nil
      
      var trashMarker = marker as! TrashMarker
      AF.request("https://ramranch.appspot.com/clean-site?id=\(trashMarker.photoid)")
    }))
    
    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .destructive, handler: { _ in
      print("The \"Cancel\" alert occured.\n")
      // ie. do nothing
    }))
    
    self.present(alert, animated: true, completion: nil)
  }
}

