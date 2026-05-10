//
//  MainViewModel.swift
//  MesopotamiaWays
//

import Foundation
import Combine
import SwiftUI
import FirebaseFirestore

class MainViewModel: ObservableObject {
    @Published var hotels: [HotelsModel] = []
    @Published var places: [PlacesModel] = []
    @Published var restaurants: [RestaurantsModel] = []
    @Published var tours: [ToursModel] = []
    
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    
    init() {
        startRealTimeListeners()
    }
    
    deinit {
        listeners.forEach { $0.remove() }
    }
    
    func startRealTimeListeners() {
        isLoading = true
        
        // Otelleri Dinle
        let hotelListener = db.collection("hotels").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let snapshot = snapshot {
                withAnimation(.easeInOut) {
                    self.hotels = snapshot.documents.compactMap { doc in
                        try? doc.data(as: HotelsModel.self)
                    }
                }
            }
            self.checkLoadingStatus()
        }
        listeners.append(hotelListener)
        
        // Mekanları Dinle
        let placeListener = db.collection("places").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let snapshot = snapshot {
                withAnimation(.easeInOut) {
                    self.places = snapshot.documents.compactMap { doc in
                        try? doc.data(as: PlacesModel.self)
                    }
                }
            }
            self.checkLoadingStatus()
        }
        listeners.append(placeListener)
        
        // Restoranları Dinle
        let restaurantListener = db.collection("restaurants").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let snapshot = snapshot {
                withAnimation(.easeInOut) {
                    self.restaurants = snapshot.documents.compactMap { doc in
                        try? doc.data(as: RestaurantsModel.self)
                    }
                }
            }
            self.checkLoadingStatus()
        }
        listeners.append(restaurantListener)
        
        // Turları Dinle
        let tourListener = db.collection("tours").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let snapshot = snapshot {
                withAnimation(.easeInOut) {
                    self.tours = snapshot.documents.compactMap { doc in
                        try? doc.data(as: ToursModel.self)
                    }
                }
            }
            self.checkLoadingStatus()
        }
        listeners.append(tourListener)
    }
    
    private func checkLoadingStatus() {
        // Basit bir kontrol, veriler geldikçe loading'i kapatabiliriz
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func fetchAllData() {
        // Manuel yenileme için de kullanılabilir, dinleyiciler zaten güncel tutar
        startRealTimeListeners()
    }
}
