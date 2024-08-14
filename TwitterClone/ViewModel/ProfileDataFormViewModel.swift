//
//  ProfileDataFormViewModel.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/10/24.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import FirebaseStorage
import FirebaseAuth

final class ProfileDataFormViewModel {
    
    private let disposeBag = DisposeBag()
    
    // Observables
    var displayName = BehaviorRelay<String?>(value: nil)
    var username = BehaviorRelay<String?>(value: nil)
    var bio = BehaviorRelay<String?>(value: nil)
    var avatarPath = BehaviorRelay<String?>(value: nil)
    var imageData = BehaviorRelay<UIImage?>(value: nil)
    var isFormValid = BehaviorRelay<Bool>(value: false)
    var isOnboardingFinished = BehaviorRelay<Bool>(value: false)
    
    let error = PublishRelay<String>()
    
    func validateUserProfileForm() {
        let displayName = self.displayName.value
        let username = self.username.value
        let bio = self.bio.value
        let imageData = self.imageData.value
        
        let isValid = (displayName?.count ?? 0) > 2 &&
                      (username?.count ?? 0) > 2 &&
                      (bio?.count ?? 0) > 2 &&
                      imageData != nil
        
        isFormValid.accept(isValid)
    }
    
    func uploadAvatar() {
        let randomID = UUID().uuidString
        guard let imageData = self.imageData.value?.jpegData(compressionQuality: 0.5) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        StorageManager.shared.uploadProfilePhoto(with: randomID, image: imageData, metaData: metaData)
            .flatMap { metaData in
                StorageManager.shared.getDownloadUrl(for: metaData.path)
            }
            .subscribe(onNext: { [weak self] url in
                self?.avatarPath.accept(url.absoluteString)
            }, onError: { [weak self] error in
                self?.error.accept(error.localizedDescription)
            }, onCompleted: { [weak self] in
                self?.updateUserData()
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUserData() {
        guard let displayName = self.displayName.value,
              let username = self.username.value,
              let bio = self.bio.value,
              let avatarPath = self.avatarPath.value,
              let id = Auth.auth().currentUser?.uid else { return }
        
        let updatedFields: [String: Any] = [
            "displayName": displayName,
            "username": username,
            "bio": bio,
            "avatarPath": avatarPath,
            "isUserOnboarded": true
        ]
        
        DatabaseManager.shared.collectionUsers(updateFields: updatedFields, for: id)
            .subscribe(onNext: { [weak self] onboardingState in
                self?.isOnboardingFinished.accept(onboardingState)
            }, onError: { [weak self] error in
                self?.error.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
