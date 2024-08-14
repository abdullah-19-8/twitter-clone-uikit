//
//  DatabaseManager.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/9/24.
//

import Foundation
import Firebase
import FirebaseAuth
import RxSwift
import RxCocoa
import FirebaseFirestore

class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    let db = Firestore.firestore()
    let usersPath: String = "users"
    let tweetsPath: String = "tweets"
    let followingPath: String = "followings"
    
    private let disposeBag = DisposeBag()
    
    func collectionUsers(add user: User) -> Observable<Bool> {
        let twitterUser = TwitterUser(from: user)
        return Observable.create { observer in
            do {
                try self.db.collection(self.usersPath).document(twitterUser.id).setData(from: twitterUser) { error in
                    if let error = error {
                        observer.onError(error)
                    } else {
                        observer.onNext(true)
                        observer.onCompleted()
                    }
                }
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func collectionUsers(retreive id: String) -> Observable<TwitterUser> {
        return Observable.create { observer in
            self.db.collection(self.usersPath).document(id).getDocument { document, error in
                if let error = error {
                    observer.onError(error)
                } else if let document = document {
                    do {
                        let twitterUser = try document.data(as: TwitterUser.self)
                        observer.onNext(twitterUser)
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    func collectionUsers(updateFields: [String: Any], for id: String) -> Observable<Bool> {
        return Observable.create { observer in
            self.db.collection(self.usersPath).document(id).updateData(updateFields) { error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(true)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    func collectionTweets(dispatch tweet: Tweet) -> Observable<Bool> {
        return Observable.create { observer in
            do{
                try self.db.collection(self.tweetsPath).document(tweet.id).setData(from: tweet) { error in
                    if let error = error {
                        observer.onError(error)
                    } else {
                        observer.onNext(true)
                        observer.onCompleted()
                    }
                }
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func collectionTweets(retreiveTweets userID: String) -> Observable<[Tweet]> {
        return Observable.create { observer in
            self.db.collection(self.tweetsPath).whereField("authorID", isEqualTo: userID).getDocuments { snapshot, error in
                if let error = error {
                    observer.onError(error)
                } else if let snapshot = snapshot {
                    do {
                        let tweets = try snapshot.documents.map { document in
                            try document.data(as: Tweet.self)
                        }
                        observer.onNext(tweets)
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    func collectionUsers(search query: String) -> Observable<[TwitterUser]> {
        return Observable.create { observer in
            self.db.collection(self.usersPath).whereField("username", isEqualTo: query).getDocuments { snapshot, error in
                if let error = error {
                    observer.onError(error)
                } else if let snapshot = snapshot {
                    do {
                        let users = try snapshot.documents.map { document in
                            try document.data(as: TwitterUser.self)
                        }
                        observer.onNext(users)
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    func collectionFollowings(isFollower: String, following: String) -> Observable<Bool> {
        return Observable.create { observer in
            self.db.collection(self.followingPath)
                .whereField("follower", isEqualTo: isFollower)
                .whereField("following", isEqualTo: following)
                .getDocuments { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                    } else if let snapshot = snapshot {
                        observer.onNext(!snapshot.isEmpty)
                        observer.onCompleted()
                    }
                }
            return Disposables.create()
        }
    }
    
    func collectionFollowings(follower: String, following: String) -> Observable<Bool> {
        return Observable.create { observer in
            self.db.collection(self.followingPath).document().setData([
                "follower": follower,
                "following": following
            ]) { error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(true)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    func collectionFollowings(delete follower: String, following: String) -> Observable<Bool> {
        return Observable.create { observer in
            self.db.collection(self.followingPath)
                .whereField("follower", isEqualTo: follower)
                .whereField("following", isEqualTo: following)
                .getDocuments { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                    } else if let document = snapshot?.documents.first {
                        document.reference.delete { error in
                            if let error = error {
                                observer.onError(error)
                            } else {
                                observer.onNext(true)
                                observer.onCompleted()
                            }
                        }
                    } else {
                        observer.onNext(false)
                        observer.onCompleted()
                    }
                }
            return Disposables.create()
        }
    }
}
