//
//  HomeViewController.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 6/26/24.
//

import UIKit
import FirebaseAuth
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    private var viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    
    private lazy var composeTweetButton: UIButton = {
        let button = UIButton(type: .system, primaryAction: UIAction { [weak self] _ in
            self?.navigateToTweetComposer()
        })
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .twitterBlueColor
        button.tintColor = .white
        let plusSign = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold))
        button.setImage(plusSign, for: .normal)
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        
        return button
    }()
    
    private func configureNavigationBar() {
        let size:CGFloat = 36
        let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = UIImage(named: "xLogo")
        
        let middleView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        middleView.addSubview(logoImageView)
        navigationItem.titleView = middleView
        
        let profileImage = UIImage(systemName: "person")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: profileImage, style: .plain, target: self, action: #selector(didTapProfile))
    }
    
    @objc private func didTapProfile(){
        guard let user = viewModel.user.value else { return }
        let profileViewModel = ProfileViewModel(user: user)
        let vc = ProfileViewController(viewModel: profileViewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private let timelineTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TweetTableViewCell.self, forCellReuseIdentifier: TweetTableViewCell.identifier)
        return tableView
    }()
    
    @objc private func didTapSignOut() {
        try? Auth.auth().signOut()
        handleAuthentication()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(timelineTableView)
        view.addSubview(composeTweetButton)
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        configureNavigationBar()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .plain, target: self, action: #selector(didTapSignOut))
        bindViews()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timelineTableView.frame = view.frame
        configureConstraints()
    }
    
    private func handleAuthentication() {
        if Auth.auth().currentUser == nil {
            let vc = UINavigationController(rootViewController: OnboardingViewController())
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    private func navigateToTweetComposer() {
        let vc = UINavigationController(rootViewController: TweetComposeViewController())
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        
        handleAuthentication()
        viewModel.retreiveUser()
    }
    
    func completeUserOnboarding() {
        let vc = ProfileDataFormViewController()
        present(vc, animated: true)
    }
    
    func bindViews() {
        viewModel.user
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] user in
                if !user.isUserOnboarded {
                    self?.completeUserOnboarding()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.tweets
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.timelineTableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func configureConstraints() {
        let composeTweetButtonConstraints = [
            composeTweetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            composeTweetButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
            composeTweetButton.heightAnchor.constraint(equalToConstant: 60),
            composeTweetButton.widthAnchor.constraint(equalToConstant: 60)
        ]
        
        NSLayoutConstraint.activate(composeTweetButtonConstraints)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
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
        
        cell.delegate = self
        return cell
    }
}

extension HomeViewController: TweetTableViewCellDelegate {
    func tweetTableViewCellDidTapReply() {
        print("Reply")
    }
    
    func tweetTableViewCellDidTapRetweet() {
        print("Retweet")
    }
    
    func tweetTableViewCellDidTapLike() {
        print("Like")
    }
    
    func tweetTableViewCellDidTapShare() {
        print("Share")
    }
}
