//
//  RestaurantsModel.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 1.12.2025.
//

import Foundation
import CoreLocation

struct RestaurantsModel : Identifiable {
    var id : Int
    var name : String
    var description : String
    var image : [String]
    
    var coordinate : CoordinateModel
    
    var location : CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}


struct CoordinateModel : Identifiable {
    var id : Int
    var latitude : Double
    var longitude : Double
}


let HamdaniRestaurant = RestaurantsModel(id: 1, name: "Hamdani Restaurant", description: "nice", image: ["Hamdani", "Hamdani2"], coordinate: CoordinateModel(id: 1, latitude: 37.32251936526379, longitude:  40.730032655052774))
let leyli = RestaurantsModel(id: 2, name: "Leyli Resturant", description: "its nice", image: ["leyli", "leyli2"], coordinate: CoordinateModel(id: 2, latitude: 37.31621498520392,  longitude: 40.734372110798795))

let resturans : [RestaurantsModel] = [HamdaniRestaurant , leyli]
