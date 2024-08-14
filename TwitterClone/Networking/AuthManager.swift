//
//  AuthManager.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/8/24.
//

import Foundation
import FirebaseAuth
import RxSwift

class AuthManager {
    
    static let shared = AuthManager()
    
    func registerUser(with email: String, password: String) -> Single<User> {
        return Single<User>.create { single in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    single(.failure(error))
                } else if let user = result?.user {
                    single(.success(user))
                }
            }
            return Disposables.create()
        }
    }
    
    func loginUser(with email: String, password: String) -> Single<User> {
        return Single<User>.create { single in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    single(.failure(error))
                } else if let user = result?.user {
                    single(.success(user))
                }
            }
            return Disposables.create()
        }
    }
}
