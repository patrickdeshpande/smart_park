//
//  parkingMeter.swift
//  Smart Park
//
//  Created by Patrick Deshpande on 7/16/16.
//  Copyright © 2016 Patrick Deshpande. All rights reserved.
//

import Foundation

class parkingMeter {
    init(id: Int, latitude:Double, longitude:Double, userID:String!, arrived:Bool!){
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.userID = userID
        self.arrived = arrived
    }
    var id: Int!
    var latitude: Double!
    var longitude: Double!
    var userID: String!
    var arrived: Bool!
    
    func printInfo(){
        print("\(id)")
        print("\(latitude)")
        print("\(longitude)")
        print("\(userID)")
        print("\(arrived)")
    }
}