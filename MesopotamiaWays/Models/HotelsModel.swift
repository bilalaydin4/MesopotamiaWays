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
    var city: String = "Mardin"
    var district: String // ✅ İLÇE EKLENDİ (Artuklu, Midyat, Nusaybin vb.)
    var shortDescription: String
    var hotelDescription: String
    var hotelImage: [String]
    
    var starCount: Int
    var rating: Double = 0.0
    var reviewCount: Int = 0
    
    var oneNightPriceForOnePerson : Double
    var oneNightPriceForTwoPeople : Double
    
    var coordinate : HotelCoordinates
    var phoneNumber : String
    var email: String = ""
    var address: String = ""
    
    var amenities: [String] = []
    
    var location : CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}


struct HotelCoordinates: Identifiable {
    var id : Int
    var latitude: Double
    var longitude: Double
}

let buyukMardinOteli = HotelsModel(
    id: 1,
    hotelName: "Büyük Mardin Oteli",
    city: "Mardin",
    district: "Artuklu", // ✅ İLÇE
    shortDescription: "Tarihi dokuda modern konfor",
    hotelDescription: "Güzel ve Temiz bir konaklama...",
    hotelImage: ["buyukMardinOteli", "buyukMardinOteli2"],
    starCount: 4,
    rating: 4.5,
    reviewCount: 128,
    oneNightPriceForOnePerson: 1200,
    oneNightPriceForTwoPeople: 2400,
    coordinate: HotelCoordinates(id: 1, latitude: 37.3102, longitude: 40.7296),
    phoneNumber: "+905432145678",
    email: "info@buyukmardin.com",
    address: "Medrese Mah. No:15, Artuklu/Mardin",
    amenities: ["wifi", "parking", "breakfast", "spa"]
)

let yayGrand = HotelsModel(
    id: 2,
    hotelName: "Mardin Yay Grand",
    city: "Mardin",
    district: "Artuklu", // ✅ İLÇE
    shortDescription: "Tarihi Modern bir konaklama",
    hotelDescription: "Tarihi Modern bir konaklama...",
    hotelImage: ["yayGrand","yayGrand2","yayGrand3"],
    starCount: 5,
    rating: 4.8,
    reviewCount: 256,
    oneNightPriceForOnePerson: 1400,
    oneNightPriceForTwoPeople: 2500,
    coordinate: HotelCoordinates(id: 2, latitude: 37.3367, longitude: 40.6960),
    phoneNumber: "+905551234567",
    email: "info@yaygrand.com",
    address: "Cumhuriyet Mah. No:45, Artuklu/Mardin",
    amenities: ["wifi", "parking", "breakfast", "pool", "spa", "fitness"]
)

// Midyat'tan örnek otel
let midyatSarayi = HotelsModel(
    id: 3,
    hotelName: "Midyat Sarayı",
    city: "Mardin",
    district: "Midyat", // ✅ FARKLI İLÇE
    shortDescription: "Taş konaklarda otantik deneyim",
    hotelDescription: "Tarihi taş konaklarda otantik bir konaklama deneyimi...",
    hotelImage: ["midyatSarayi", "midyatSarayi2"],
    starCount: 3,
    rating: 4.2,
    reviewCount: 89,
    oneNightPriceForOnePerson: 800,
    oneNightPriceForTwoPeople: 1500,
    coordinate: HotelCoordinates(id: 3, latitude: 37.4190, longitude: 41.3390),
    phoneNumber: "+905332211445",
    email: "info@midyatsarayi.com",
    address: "Cumhuriyet Cad. No:23, Midyat/Mardin",
    amenities: ["wifi", "breakfast", "terrace"]
)

let hotels : [HotelsModel] = [buyukMardinOteli, yayGrand, midyatSarayi]



/*

 let mardinDistricts = [
 "Artuklu",     // Merkez
 "Midyat",      // Turistik
 "Nusaybin",    // Sınır ilçesi
 "Kızıltepe",   // Büyük ilçe
 "Derik",
 "Mazıdağı",
 "Dargeçit",
 "Savur",
 "Ömerli",
 "Yeşilli"
]
 
 // İlçelere göre gruplama
 let groupedByDistrict = Dictionary(grouping: hotels, by: { $0.district })
 // ["Artuklu": [buyukMardinOteli, yayGrand], "Midyat": [midyatSarayi]]
 
 */
