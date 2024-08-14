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
    
    private let disposeBag = DisposeBag()
    private var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    private lazy var timelineTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TweetTableViewCell.self, forCellReuseIdentifier: TweetTableViewCell.identifier)
        return tableView
    }()
    
    private func configureNavigationBar() {
        let size: CGFloat = 36
        let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = UIImage(named: "xLogo")
        
        let middleView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        middleView.addSubview(logoImageView)
        navigationItem.titleView = middleView
        
        let profileImage = UIImage(systemName: "person")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: profileImage, style: .plain, target: self, action: #selector(didTapProfile))
    }
    
    @objc private func didTapProfile() {
        let profileViewModel = ProfileViewModel(user: viewModel.user?.value ?? TwitterUser.default)
        let vc = ProfileViewController(viewModel: profileViewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapSignOut() {
        try? Auth.auth().signOut()
        handleAuthentication()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(timelineTableView)
        view.addSubview(composeTweetButton)
        
        configureNavigationBar()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .plain, target: self, action: #selector(didTapSignOut))
        
        bindViews()
        configureConstraints()
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
    
    private func navigateToTweetComposer() {
        let vc = UINavigationController(rootViewController: TweetComposeViewController())
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func handleAuthentication() {
        if Auth.auth().currentUser == nil {
            let vc = UINavigationController(rootViewController: OnboardingViewController())
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    private func bindViews() {
        // Bind user to check for onboarding
        viewModel.user?
            .compactMap { $0 }
            .filter { !$0.isUserOnboarded }
            .bind { [weak self] _ in
                self?.completeUserOnboarding()
            }
            .disposed(by: disposeBag)
        
        // Bind tweets to reload table view
        viewModel.tweets
            .bind(to: timelineTableView.rx.items(cellIdentifier: TweetTableViewCell.identifier, cellType: TweetTableViewCell.self)) { index, tweet, cell in
                cell.configureTweet(with: tweet.author.displayName,
                                    username: tweet.author.username,
                                    tweetTextContent: tweet.tweetContent,
                                    avatarPath: tweet.author.avatarPath)
            }
            .disposed(by: disposeBag)
        
        // Handle tweet cell button taps
        timelineTableView.rx.itemSelected
            .bind { [weak self] indexPath in
                let tweet = self?.viewModel.tweets.value[indexPath.row]
                print("Selected tweet: \(String(describing: tweet))")
            }
            .disposed(by: disposeBag)
        
        // Handle compose tweet button tap
        composeTweetButton.rx.tap
            .bind { [weak self] in
                self?.navigateToTweetComposer()
            }
            .disposed(by: disposeBag)
    }
    
    private func configureConstraints() {
        let composeTweetButtonConstraints = [
            composeTweetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            composeTweetButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
            composeTweetButton.heightAnchor.constraint(equalToConstant: 60),
            composeTweetButton.widthAnchor.constraint(equalToConstant: 60)
        ]
        
        let timelineTableViewConstraints = [
            timelineTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timelineTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timelineTableView.topAnchor.constraint(equalTo: view.topAnchor),
            timelineTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(composeTweetButtonConstraints)
        NSLayoutConstraint.activate(timelineTableViewConstraints)
    }
}

