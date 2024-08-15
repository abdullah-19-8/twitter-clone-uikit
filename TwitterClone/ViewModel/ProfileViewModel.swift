//
//  ProfileViewModel.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/11/24.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth

enum ProfileFollowingState {
    case userIsFollowed
    case userIsUnFollowed
    case personal
}

final class ProfileViewModel {
    
    private let disposeBag = DisposeBag()
    
    // RxSwift observables
    var user: BehaviorRelay<TwitterUser>
    var error = PublishRelay<String>()
    var tweets = BehaviorRelay<[Tweet]>(value: [])
    let currentFollowingState = BehaviorRelay<ProfileFollowingState>(value: .personal)
    
    init(user: TwitterUser) {
        self.user = BehaviorRelay(value: user)
        checkIfFollowed()
    }
    
    private func checkIfFollowed() {
        guard let personalUserID = Auth.auth().currentUser?.uid,
              personalUserID != user.value.id else {
            currentFollowingState.accept(.personal)
            return
        }
        
        DatabaseManager.shared.collectionFollowings(isFollower: personalUserID, following: user.value.id)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isFollowed in
                self?.currentFollowingState.accept(isFollowed ? .userIsFollowed : .userIsUnFollowed)
            }, onError: { [weak self] error in
                self?.error.accept(error.localizedDescription)
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func follow() {
        guard let personalUserID = Auth.auth().currentUser?.uid else { return }
        
        DatabaseManager.shared.collectionFollowings(follower: personalUserID, add: user.value.id)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                DatabaseManager.shared.collectionFollowings(add: personalUserID, following: self?.user.value.id ?? "")
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] _ in
                        self?.currentFollowingState.accept(.userIsFollowed)
                    }, onError: { [weak self] error in
                        self?.error.accept(error.localizedDescription)
                        print(error.localizedDescription)
                    })
                    .disposed(by: self?.disposeBag ?? DisposeBag())
            }, onError: { [weak self] error in
                self?.error.accept(error.localizedDescription)
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func unFollow() {
        guard let personalUserID = Auth.auth().currentUser?.uid else { return }
        
        DatabaseManager.shared.collectionFollowings(delete: personalUserID, following: user.value.id)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                DatabaseManager.shared.collectionFollowings(follower: personalUserID, delete: self?.user.value.id ?? "")
                    .observe(on: MainScheduler.instance)
                    .subscribe (onNext: { [weak self] _ in
                        self?.currentFollowingState.accept(.userIsUnFollowed)
                    }, onError: { [weak self] error in
                        self?.error.accept(error.localizedDescription)
                        print(error.localizedDescription)
                    })
                    .disposed(by: self?.disposeBag ?? DisposeBag())
            }, 
                       onError: { [weak self] error in
                    self?.error.accept(error.localizedDescription)
                    print(error.localizedDescription)
                })
            .disposed(by: disposeBag)
    }
    
    func fetchUserTweets() {
        DatabaseManager.shared.collectionTweets(retreiveTweets: user.value.id)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] tweets in
                self?.tweets.accept(tweets)
            }, onError: { [weak self] error in
                self?.error.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func getFormattedDate(with date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM YYYY"
        return dateFormatter.string(from: date)
    }
    
    func fetchFollowers() -> Observable<[Followers]> {
        return DatabaseManager.shared.fetchFollowers(userId: user.value.id)
                .observe(on: MainScheduler.instance)
    }
    
    func fetchFollowings() -> Observable<[Followings]> {
        return DatabaseManager.shared.fetchFollowings(userId: user.value.id)
                .observe(on: MainScheduler.instance)
    }
}
