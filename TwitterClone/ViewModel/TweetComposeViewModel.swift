//
//  TweetComposeViewModel.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/12/24.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth

final class TweetComposeViewModel {
    
    private let disposeBag = DisposeBag()
    
    // RxSwift observables
    var isValidToTweet = BehaviorRelay<Bool>(value: false)
    var error = PublishRelay<String>()
    var shouldDismissComposer = BehaviorRelay<Bool>(value: false)
    var tweetContent = ""
    private var user: TwitterUser?
    
    func getUserData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        DatabaseManager.shared.collectionUsers(retreive: userID)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] twitterUser in
                self?.user = twitterUser
            }, onError: { [weak self] error in
                self?.error.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func validateToTweet() {
        isValidToTweet.accept(!tweetContent.isEmpty)
    }
    
    func dispatchTweet() {
        guard let user = user else { return }
        let tweet = Tweet(
            author: user,
            authorID: user.id,
            tweetContent: tweetContent,
            likesCount: 0,
            likers: [],
            isReply: false,
            paretnReference: nil
        )
        
        DatabaseManager.shared.collectionTweets(dispatch: tweet)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.shouldDismissComposer.accept(state)
            }, onError: { [weak self] error in
                self?.error.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
