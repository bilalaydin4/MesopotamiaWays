//
//  OtelsModel.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 28.11.2025.
//

import Foundation
import CoreLocation

struct HotelsModel : Identifiable {
    var id : Int
    var hotelName: String
    var hotelDescription: String
    var hotelImage: [String]
    var oneNightPriceForOnePerson : Double
    var oneNightPriceForTwoPeople : Double
    var coordinate : HotelCoordinates
   // var phoneNumber : String = "+905432145678"
    
    var location : CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
}


struct HotelCoordinates: Identifiable {
    var id : Int
    var latitude: Double
    var longitude: Double
}

let buyukMardinOteli = HotelsModel(id: 1, hotelName: "Büyük Mardin Oteli", hotelDescription: "Güzel ve Temiz bir konaklama.", hotelImage: ["buyukMardinOteli", "buyukMardinOteli2", "buyukMardinOteli3"], oneNightPriceForOnePerson: 1200, oneNightPriceForTwoPeople: 2400, coordinate: HotelCoordinates(id: 1, latitude: 37.31023030572992,  longitude: 40.729675110035856))

let yayGrand = HotelsModel(id: 2, hotelName: "Mardin Yay Grand", hotelDescription: "Tarihi Modern bir konaklama.", hotelImage: ["yayGrand","yayGrand2","yayGrand3"], oneNightPriceForOnePerson: 1400, oneNightPriceForTwoPeople: 2500, coordinate: HotelCoordinates(id: 2, latitude: 37.33679208781566, longitude:  40.696069896543335))

let hotels : [HotelsModel] = [buyukMardinOteli, yayGrand]
