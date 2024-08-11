//
//  StorageManager.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/11/24.
//

import Foundation
import Combine
import FirebaseStorage
import FirebaseStorageCombineSwift

enum FireStorageError: Error {
    case invaledImageID
}

final class StorageManager {
    
    static let shared = StorageManager()
    
    let storage = Storage.storage()
    
    func getDownloadUrl(for id: String?) -> AnyPublisher<URL, Error> {
        guard let id else{
            return Fail(error: FireStorageError.invaledImageID)
                .eraseToAnyPublisher()
        }
        return storage
            .reference(withPath: id)
            .downloadURL()
            .print()
            .eraseToAnyPublisher()
        
    }
    
    func uploadProfilePhoto(with randomID: String, image: Data, metaData: StorageMetadata) -> AnyPublisher<StorageMetadata, Error> {
        return storage
            .reference()
            .child("images/\(randomID).jpg")
            .putData(image, metadata: metaData)
            .print()
            .eraseToAnyPublisher()
    }
}
