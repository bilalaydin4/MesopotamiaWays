//
//  ToursModel.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 3.12.2025.
//


import Foundation
import CoreLocation

struct ToursModel: Identifiable {
    var id: Int
    var name: String
    var logoImage: String
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


struct StartPoint : Identifiable {
    var id : Int
    var title : String
    var latitude : Double
    var longitude : Double
}

struct ToursCoordinates: Identifiable {
    var id : Int
    var latitude: Double
    var longitude: Double
}


let mardinGap : ToursModel = ToursModel(id: 1, name: "Mardin Gap Tour", logoImage: "gap", placesToGo: [dara, kasimiyeMedresesi, zinciriyeMedresesi], timeToGo: "20.04.2025", coordinates: ToursCoordinates(id: 1, latitude: 37.327256036662035,  longitude: 40.71634512600495), startPointCoordinates: StartPoint(id: 1, title: "Mardin Meydan", latitude: 37.31326723133702,  longitude: 40.73527689624707))


let tours : [ToursModel] = [mardinGap]
