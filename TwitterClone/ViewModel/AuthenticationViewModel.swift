//
//  RegisterViewModel.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/7/24.
//

import Foundation
import FirebaseAuth
import RxSwift
import RxCocoa

final class AuthenticationViewModel {
    
    var email = BehaviorRelay<String?>(value: nil)
    var password = BehaviorRelay<String?>(value: nil)
    var isAuthenticationFormValid = BehaviorRelay<Bool>(value: false)
    var user = PublishRelay<User?>()
    var error = PublishRelay<String?>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        Observable.combineLatest(email, password)
            .map { [weak self] email, password in
                return self?.isValidEmail(email ?? "") == true && password?.count ?? 0 >= 8
            }
            .bind(to: isAuthenticationFormValid)
            .disposed(by: disposeBag)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func createUser() {
        guard let email = email.value, let password = password.value else { return }
        
        AuthManager.shared.registerUser(with: email, password: password)
            .subscribe(onSuccess: { [weak self] user in
                self?.user.accept(user)
                self?.createRecord(for: user)
            }, onFailure: { [weak self] error in
                self?.error.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func createRecord(for user: User) {
        DatabaseManager.shared.collectionUsers(add: user)
            .subscribe(onError: { [weak self] error in
                self?.error.accept(error.localizedDescription)
            }, onCompleted: {
                print("Adding user record to database successful")
            })
            .disposed(by: disposeBag)
    }
    
    func loginUser() {
        guard let email = email.value, let password = password.value else { return }
        
        AuthManager.shared.loginUser(with: email, password: password)
            .subscribe(onSuccess: { [weak self] user in
                self?.user.accept(user)
            }, onFailure: { [weak self] error in
                self?.error.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
