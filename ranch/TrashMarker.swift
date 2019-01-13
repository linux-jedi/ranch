//
//  TrashMarker.swift
//  ranch
//
//  Created by Caleb Thomas on 1/12/19.
//  Copyright © 2019 Caleb Thomas. All rights reserved.
//

import GoogleMaps

class TrashMarker:  GMSMarker {
  var photoid :String = ""
  var clean :Bool
  
  override init() {
    self.clean = false
  }
}
