//
//  SearchViewModel.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/12/24.
//

import Foundation
import Combine

class SearchViewModel {
    
    var subscriptions: Set<AnyCancellable> = []
    
    func search(with query: String, _ completion: @escaping ([TwitterUser]) -> Void) {
        DatabaseManager.shared.collectionUsers(search: query)
            .sink { completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: { users in
                completion(users)
            }
            .store(in: &subscriptions)

    }
}
