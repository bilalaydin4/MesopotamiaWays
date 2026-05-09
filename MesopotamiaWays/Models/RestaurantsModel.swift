//
//  RestaurantsModel.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 1.12.2025.
//

import Foundation
import CoreLocation
import FirebaseFirestore

struct RestaurantsModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var image: [String] // URL array
    var coordinate: CoordinateModel
    
    var category: String?
    var priceRange: String?
    var openingHours: String?
    var phoneNumber: String?
    var email: String?
    var website: String?
    var address: String?
    var city: String?
    var district: String?
    var rating: Double?
    var reviewCount: Int?
    var features: [String]?
    
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

struct CoordinateModel: Codable {
    var latitude: Double
    var longitude: Double
}

// let HamdaniRestaurant = RestaurantsModel(...)
// let leyli = RestaurantsModel(...)
// let resturans: [RestaurantsModel] = [HamdaniRestaurant , leyli]
