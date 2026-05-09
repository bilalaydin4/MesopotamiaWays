//
//  PlaceModel.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 24.11.2025.
//

import Foundation
import CoreLocation
import FirebaseFirestore

struct PlacesModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var history: String
    var age: String
    var imageName: [String] // Artık Firebase Storage URL'lerini tutacak
    var coordinates: PlacesCoordinate
    var videoUrl: String
    var category: String? // Admin tarafında var, modele ekledik
    var entranceFee: String?
    var visitingHours: String?
    var website: String?
    var phoneNumber: String?
    var address: String?
    var interestingFact: String?
    var features: [String]? // Rehberli tur, Wifi vb.
    
    var locationCordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
}

struct PlacesCoordinate: Codable {
    var latitude: Double
    var longitude: Double
}

// MARK: - Dummy Data (Geçici)
// let mardin = PlacesModel(id: UUID().uuidString, name: "Mardin old city", history: "Eski Mardin...", age: "Yaklaşık 3.000 yaşında", imageName: ["mardin"], coordinates: PlacesCoordinate(latitude: 37.3132, longitude: 40.7353), videoUrl: "")
// let dara = PlacesModel(...)
// let zinciriyeMedresesi = PlacesModel(...)
// let kasimiyeMedresesi = PlacesModel(...)
// let placesss: [PlacesModel] = []
