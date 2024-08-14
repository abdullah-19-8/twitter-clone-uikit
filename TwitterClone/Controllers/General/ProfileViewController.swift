//
//  ProfileViewController.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 6/30/24.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage

class ProfileViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    private var isStatusBarHidden: Bool = true
    private var viewModel: ProfileViewModel
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let statusBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.opacity = 0
        return view
    }()
    
    private let profileTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TweetTableViewCell.self, forCellReuseIdentifier: TweetTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var headerView = ProfileTableViewHeader(frame: CGRect(x: 0, y: 0, width: profileTableView.frame.width, height: 390))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.title = "Profile"
        view.addSubview(profileTableView)
        view.addSubview(statusBar)
        profileTableView.delegate = nil
        profileTableView.dataSource = nil
        profileTableView.tableHeaderView = headerView
        profileTableView.contentInsetAdjustmentBehavior = .never
        navigationController?.navigationBar.isHidden = true
        configureConstraints()
        bindViews()
        viewModel.fetchUserTweets()
    }
    
    private func bindViews() {
        // Bind tweets to table view
        viewModel.tweets
            .bind(to: profileTableView.rx.items(cellIdentifier: TweetTableViewCell.identifier, cellType: TweetTableViewCell.self)) { [weak self] row, tweet, cell in
                cell.configureTweet(with: tweet.author.displayName,
                                    username: tweet.author.username,
                                    tweetTextContent: tweet.tweetContent,
                                    avatarPath: tweet.author.avatarPath)
            }
            .disposed(by: disposeBag)
        
        // Bind user info to header view
        viewModel.user
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                self?.headerView.displayNameLabel.text = user.displayName
                self?.headerView.usernameLabel.text = "@\(user.username)"
                self?.headerView.userBioLabel.text = user.bio
                self?.headerView.followingCountLabel.text = String(user.followingCount)
                self?.headerView.followersCountLabel.text = String(user.followersCount)
                self?.headerView.profileAvatarImageView.sd_setImage(with: URL(string: user.avatarPath))
                self?.headerView.joinDateLabel.text = "Joined \(self?.viewModel.getFormattedDate(with: user.createdOn) ?? "")"
            })
            .disposed(by: disposeBag)
        
        // Handle scroll view to toggle status bar visibility
        profileTableView.rx.contentOffset
            .map { $0.y }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] yPosition in
                if yPosition > 150 && self?.isStatusBarHidden == true {
                    self?.isStatusBarHidden = false
                    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear) { [weak self] in
                        self?.statusBar.layer.opacity = 1
                    }
                } else if yPosition < 0 && self?.isStatusBarHidden == false {
                    self?.isStatusBarHidden = true
                    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear) { [weak self] in
                        self?.statusBar.layer.opacity = 0
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func configureConstraints() {
        let profileTableViewConstraints = [
            profileTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileTableView.topAnchor.constraint(equalTo: view.topAnchor),
            profileTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        let statusBarConstraints = [
            statusBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusBar.topAnchor.constraint(equalTo: view.topAnchor),
            statusBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusBar.heightAnchor.constraint(equalToConstant: view.bounds.height > 800 ? 40 : 20)
        ]
        
        NSLayoutConstraint.activate(profileTableViewConstraints)
        NSLayoutConstraint.activate(statusBarConstraints)
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tweets.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.identifier, for: indexPath) as? TweetTableViewCell else {
            return UITableViewCell()
        }
        let tweet = viewModel.tweets.value[indexPath.row]
        
        cell.configureTweet(with: tweet.author.displayName,
                            username: tweet.author.username,
                            tweetTextContent: tweet.tweetContent,
                            avatarPath: tweet.author.avatarPath)
        return cell
    }
}
