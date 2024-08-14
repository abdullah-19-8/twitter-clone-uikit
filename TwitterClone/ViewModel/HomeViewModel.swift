//
//  HomeViewModel.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/10/24.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth

final class HomeViewModel {
    
    let user = BehaviorRelay<TwitterUser?>(value: nil)
    let error = BehaviorRelay<String?>(value: nil)
    let tweets = BehaviorRelay<[Tweet]>(value: [])
    
    private let disposeBag = DisposeBag()
    
    func retreiveUser() {
        guard let id = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.shared.collectionUsers(retreive: id)
            .do(onNext: { [weak self] user in
                self?.user.accept(user)
                self?.fetchTweets()
            })
            .subscribe(onNext: { [weak self] user in
                self?.user.accept(user)
            }, onError: { [weak self] error in
                self?.error.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchTweets() {
        guard let id = user.value?.id else { return }
        DatabaseManager.shared.collectionTweets(retreiveTweets: id)
            .subscribe(onNext: { [weak self] retreivedTweets in
                self?.tweets.accept(retreivedTweets)
            }, onError: { [weak self] error in
                self?.error.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
