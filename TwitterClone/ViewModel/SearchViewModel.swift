//
//  SearchViewModel.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/12/24.
//

import Foundation
import RxSwift
import RxCocoa

class SearchViewModel {
    
    private let disposeBag = DisposeBag()
    
    // Relay for handling errors or updates
    let users = PublishRelay<[TwitterUser]>()
    let error = PublishRelay<String>()
    
    func search(with query: String) {
        DatabaseManager.shared.collectionUsers(search: query)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] users in
                self?.users.accept(users)
            }, onError: { [weak self] error in
                self?.error.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}

