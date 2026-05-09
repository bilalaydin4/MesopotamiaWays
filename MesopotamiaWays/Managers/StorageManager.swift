//
//  StorageManager.swift
//  MesopotamiaWays
//

import Foundation
import FirebaseStorage
import UIKit

class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    // Çoklu resim yükleme ve URL'leri döndürme
    func uploadImages(images: [UIImage], folder: String, completion: @escaping ([String]) -> Void) {
        var uploadedURLs: [String] = []
        let group = DispatchGroup()
        
        for image in images {
            group.enter()
            
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                group.leave()
                continue
            }
            
            let imageName = UUID().uuidString
            let ref = storage.child("\(folder)/\(imageName).jpg")
            
            ref.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Failed to upload image: \(error.localizedDescription)")
                    group.leave()
                    return
                }
                
                ref.downloadURL { url, error in
                    if let url = url {
                        uploadedURLs.append(url.absoluteString)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(uploadedURLs)
        }
    }
}
