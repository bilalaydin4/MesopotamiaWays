//
//  ToursModel.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 3.12.2025.
//

import Foundation
import CoreLocation
import FirebaseFirestore

struct ToursModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var logoImage: String // Firebase Storage URL
    var placesToGo: [PlacesModel]
    var timeToGo: String
    
    var coordinates: ToursCoordinates
    var startPointCoordinates: StartPoint
    
    var startPointCoordinates2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: startPointCoordinates.latitude,
                              longitude: startPointCoordinates.longitude)
    }
    
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinates.latitude,
                              longitude: coordinates.longitude)
    }
}

struct StartPoint: Codable {
    var title: String
    var latitude: Double
    var longitude: Double
}

struct ToursCoordinates: Codable {
    var latitude: Double
    var longitude: Double
}

// let mardinGap: ToursModel = ToursModel(...)
// let tours: [ToursModel] = [mardinGap]
