//
//  StorageManager.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/11/24.
//

import Foundation
import RxSwift
import FirebaseStorage

enum FireStorageError: Error {
    case invalidImageID
}

final class StorageManager {
    
    static let shared = StorageManager()
    
    let storage = Storage.storage()
    
    func getDownloadUrl(for id: String?) -> Observable<URL> {
        guard let id else {
            return Observable.error(FireStorageError.invalidImageID)
        }
        return Observable.create { observer in
            self.storage.reference(withPath: id).downloadURL { url, error in
                if let error = error {
                    observer.onError(error)
                } else if let url = url {
                    observer.onNext(url)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    func uploadProfilePhoto(with randomID: String, image: Data, metaData: StorageMetadata) -> Observable<StorageMetadata> {
        return Observable.create { observer in
            self.storage.reference().child("images/\(randomID).jpg").putData(image, metadata: metaData) { metadata, error in
                if let error = error {
                    observer.onError(error)
                } else if let metadata = metadata {
                    observer.onNext(metadata)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}

