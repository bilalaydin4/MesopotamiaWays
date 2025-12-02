//
//  PlaceModel.swift
//  MesopotamiaWays
//
//  Created by Bilal AYDIN on 24.11.2025.
//


import Foundation
import CoreLocation

struct PlacesModel: Identifiable {
    var id : Int
    var name: String
    var history: String
    var age : String
    var imageName : [String]
    var coordinates : PlacesCoordinate
    var videoUrl : String

    
    var locationCordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
}


struct PlacesCoordinate: Identifiable {
    var id : Int
    var latitude: Double
    var longitude: Double
}


let mardin = PlacesModel(id: 1, name: "Mardin old city", history: "Eski Mardin, kökleri yaklaşık 3.000 yıl öncesine uzanan, Mardin Kalesi etrafında şekillenmiş kadim bir yerleşimdir; Süryanice “kale/tepe” anlamına gelen adıyla Roma, Bizans, Artuklular, Selçuklular ve Osmanlı gibi birçok medeniyete ev sahipliği yapmış, taş mimarisi ve katmanlı tarihiyle günümüze ulaşan çok eski bir şehirdir.", age: "Yaklaşık 3.000 yaşında bu şehir", imageName: ["mardin" , "mardin2", "mardin3", "mardin4"], coordinates: PlacesCoordinate(id: 1, latitude: 37.313211963085976, longitude: 40.73531987464163), videoUrl: "https://www.youtube.com/watch?v=3KPbAvR9IAs")

let dara = PlacesModel(id: 2, name: "Dara Antic City", history: "Dara, MS 6. yüzyılda Bizans İmparatoru Anastasius tarafından, Sasani tehdidine karşı askeri üs ve sınır kenti olarak kuruldu. Bölge, Mezopotamya’nın kuzeyindeki en önemli askeri, ticari ve idari merkezlerden biri haline geldi. Kent içinde devasa su sarnıçları, yeraltı yapıları, nekropol alanı, sur kalıntıları ve askeri depolar bulunur. Özellikle büyük yeraltı sarnıcı, Anadolu’daki en etkileyici yapılar arasındadır. Dara, Bizans–Sasani savaşlarında defalarca el değiştirdi. 7. yüzyılda Arap hakimiyetine geçtikten sonra önemini yavaş yavaş kaybetti ve zamanla küçük bir yerleşime dönüştü. Bugün Dara, Mardin’in en dikkat çekici tarihi alanlarından biridir; kazılar hâlâ devam ediyor.", age: "Yaklaşık 1.500 yaşında", imageName: ["dara","dara"], coordinates: PlacesCoordinate(id: 2, latitude: 37.17783801438008, longitude:  40.94826497717714), videoUrl: "https://www.youtube.com/watch?v=3KPbAvR9IAs")

let zinciriyeMedresesi = PlacesModel(id: 3, name: "Zinciriye medresesi", history: "Zinciriye Medresesi, 1385 yılında Artuklu Sultanı Melik Necmeddin İsa tarafından yaptırılan, Mardin’in en etkileyici tarihi yapılarından biridir. Geniş avlusu, iki katlı mimarisi, kubbeleri ve etkileyici taş işçiliğiyle dikkat çeker. Hem bir eğitim yapısı hem de rasathane olarak kullanılmıştır. Mardin Kalesi’nin hemen altında yer aldığı için şehrin manzarasını en güzel gören noktalardan biridir ve Artuklu döneminin zarif taş ustalığını günümüze taşıyan önemli bir eserdir.", age: "yaklaşık 640 yaşındadır.", imageName: ["zinciriyeMedresesi","zinciriyeMedresesi"], coordinates: PlacesCoordinate(id: 3, latitude: 37.31428327966112, longitude:  40.74005785718501), videoUrl: "https://www.youtube.com/watch?v=3KPbAvR9IAs")

let kasimiyeMedresesi = PlacesModel(id: 4, name: "Kasımiye Medresesi", history: "Kasımiye Medresesi, Mardin’in en büyük ve etkileyici medreselerinden biridir. 15. yüzyılın sonlarında Artuklu ve Memluk etkisiyle yapılmış, tamamlanması 1524 yılında gerçekleşmiştir. İki katlı, geniş avlulu ve taş işçiliğiyle dikkat çeken bu medrese, hem eğitim hem de dini amaçlarla kullanılmıştır ve Mardin’in tarihi dokusunun önemli bir parçasıdır.", age: "2025 yılı itibarıyla yaklaşık 500 yıl", imageName: ["kasimiyeMedresesi","kasimiyeMedresesi"], coordinates: PlacesCoordinate(id: 3, latitude: 37.307791312914816, longitude:  40.719996067976), videoUrl: "https://www.youtube.com/watch?v=3KPbAvR9IAs")


let placesss : [PlacesModel] = [dara, mardin, zinciriyeMedresesi, kasimiyeMedresesi]


