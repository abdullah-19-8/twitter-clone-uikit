//
//  ProfileViewModel.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/11/24.
//

import Foundation
import Combine
import FirebaseAuth

enum ProfileFollowingState {
    case userIsFollowed
    case userIsUnFollowed
    case personal
}

final class ProfileViewModel: ObservableObject {
    
    @Published var user: TwitterUser
    @Published var error: String?
    @Published var tweets: [Tweet] = []
    @Published var currentFollowingState: ProfileFollowingState = .personal
    
    init(user: TwitterUser) {
        self.user = user
        checkIfFollowed()
    }
    
    private func checkIfFollowed() {
        guard let personalUserID = Auth.auth().currentUser?.uid,
              personalUserID != user.id
        else {
            currentFollowingState = .personal
            return
        }
        DatabaseManager.shared.collectionFollowings(isFollower: personalUserID, following: user.id)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.error = error.localizedDescription
                    
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] isFollowed in
                self?.currentFollowingState = isFollowed ? .userIsFollowed : .userIsUnFollowed
            }
            .store(in: &subscription)
    }
    
    private var subscription: Set<AnyCancellable> = []
    
    func follow() {
        guard let personalUserID = Auth.auth().currentUser?.uid else { return }
        
        DatabaseManager.shared.collectionFollowings(follower: personalUserID, following: user.id)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.error = error.localizedDescription
                    
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] _ in
                self?.currentFollowingState = .userIsFollowed
            }
            .store(in: &subscription)

    }
    
    func unFollow() {
        guard let personalUserID = Auth.auth().currentUser?.uid else { return }
        
        DatabaseManager.shared.collectionFollowings(delete: personalUserID, following: user.id)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.error = error.localizedDescription
                    
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] _ in
                self?.currentFollowingState = .userIsUnFollowed
            }
            .store(in: &subscription)
    }
    
    func fetchUserTweets() {
        DatabaseManager.shared.collectionTweets(retreiveTweets: user.id)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] tweets in
                self?.tweets = tweets
            }
            .store(in: &subscription)
    }
    
    func getFormattedDate(with date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM YYYY"
        return dateFormatter.string(from: date)
    }
}
