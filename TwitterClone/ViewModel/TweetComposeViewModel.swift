//
//  TweetComposeViewModel.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/12/24.
//

import Foundation
import Combine
import FirebaseAuth

final class TweetComposeViewModel: ObservableObject {
    
    private var subscriptions: Set<AnyCancellable> = []
    
    @Published var isValedToTweet: Bool = false
    @Published var error: String = ""
    @Published var shouldDismissComposer: Bool = false
    var tweetContent = ""
    private var user: TwitterUser?
    
    func getUserData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.shared.collectionUsers(retreive: userID)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self]  twitterUser in
                self?.user = twitterUser
            }
            .store(in: &subscriptions)
    }
    
    func validateToTweet() {
        isValedToTweet = !tweetContent.isEmpty
    }
    
    func dispatchTweet() {
        guard let user else { return }
        let tweet = Tweet(author: user, authorID: user.id, tweetContent: tweetContent, likesCount: 0, likers: [], isReply: false, paretnReference: nil)
        DatabaseManager.shared.collectionTweets(dispatch: tweet)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] state in
                self?.shouldDismissComposer = state
            }
            .store(in: &subscriptions)

    }
}
