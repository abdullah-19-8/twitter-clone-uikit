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
    
    let isValidToTweet = BehaviorRelay<Bool>(value: false) // Corrected the typo here
    let error = BehaviorRelay<String>(value: "")
    let shouldDismissComposer = BehaviorRelay<Bool>(value: false)
    
    var tweetContent = ""
    private var user: TwitterUser?
    private let disposeBag = DisposeBag()
    
    func getUserData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.shared.collectionUsers(retreive: userID)
            .subscribe(onNext: { [weak self] twitterUser in
                self?.user = twitterUser
            }, onError: { [weak self] error in
                self?.error.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func validateToTweet() {
        isValidToTweet.accept(!tweetContent.isEmpty) // Use the corrected property name here
    }
    
    func dispatchTweet() {
        guard let user else { return }
        let tweet = Tweet(author: user, authorID: user.id, tweetContent: tweetContent, likesCount: 0, likers: [], isReply: false, paretnReference: nil)
        DatabaseManager.shared.collectionTweets(dispatch: tweet)
            .subscribe(onNext: { [weak self] state in
                self?.shouldDismissComposer.accept(state)
            }, onError: { [weak self] error in
                self?.error.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
