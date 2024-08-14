//
//  HomeViewModel.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/10/24.
//

import Foundation
import FirebaseAuth
import RxSwift
import RxCocoa

final class HomeViewModel {
    
    var user: BehaviorRelay<TwitterUser?>?
    var error = PublishRelay<String>()
    var tweets = BehaviorRelay<[Tweet]>(value: [])
    
    private let disposeBag = DisposeBag()
    
    init(user: TwitterUser?) {
        self.user = BehaviorRelay(value: user)
        retreiveUser()
    }
    
    func retreiveUser() {
        guard let id = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.shared.collectionUsers(retreive: id)
            .observe(on: MainScheduler.instance)
            .subscribe (onNext: { [weak self] user in
                self?.user?.accept(user)
            }, onError: { [weak self] error in
                self?.error.accept(error.localizedDescription)
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchTweets() {
        DatabaseManager.shared.collectionTweets(retreiveTweets: user?.value?.id ?? "")
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] tweets in
                self?.tweets.accept(tweets)
            }, onError: { [weak self] error in
                self?.error.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
}
