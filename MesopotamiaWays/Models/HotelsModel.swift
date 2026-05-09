//
//  OtelsModel.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 28.11.2025.
//

import Foundation
import CoreLocation
import FirebaseFirestore

struct HotelsModel: Identifiable, Codable {
    @DocumentID var id: String?
    var hotelName: String
    var city: String
    var district: String 
    var shortDescription: String
    var hotelDescription: String
    var hotelImage: [String] // URL array
    
    var starCount: Int
    var rating: Double
    var reviewCount: Int
    
    var oneNightPriceForOnePerson: Double
    var oneNightPriceForTwoPeople: Double
    
    var coordinate: HotelCoordinates
    var phoneNumber: String
    var email: String
    var address: String
    
    var amenities: [String]
    
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

struct HotelCoordinates: Codable {
    var latitude: Double
    var longitude: Double
}

// let buyukMardinOteli = HotelsModel(...)
// let yayGrand = HotelsModel(...)
// let midyatSarayi = HotelsModel(...)
// let hotels: [HotelsModel] = [buyukMardinOteli, yayGrand, midyatSarayi]
