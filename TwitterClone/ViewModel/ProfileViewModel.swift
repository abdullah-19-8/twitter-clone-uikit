//
//  ProfileViewModel.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/11/24.
//

import Foundation
import Combine
import FirebaseAuth

final class ProfileViewModel: ObservableObject {
    
    @Published var user: TwitterUser
    @Published var error: String?
    @Published var tweets: [Tweet] = []
    
    init(user: TwitterUser) {
        self.user = user
    }
    
    private var subscription: Set<AnyCancellable> = []
    
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
