//
//  SearchResultsViewController.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/12/24.
//

import UIKit
import RxSwift
import RxCocoa

class SearchResultsViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let usersSubject = BehaviorSubject<[TwitterUser]>(value: [])
    
    private let searchResultsTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(searchResultsTableView)
        configureConstraints()
        
        setupBindings()
    }
    
    func update(users: [TwitterUser]) {
        usersSubject.onNext(users)
    }
    
    private func setupBindings() {
        // Bind the users array to the table view
        usersSubject
            .bind(to: searchResultsTableView.rx.items(cellIdentifier: UserTableViewCell.identifier, cellType: UserTableViewCell.self)) { index, user, cell in
                cell.configure(with: user)
            }
            .disposed(by: disposeBag)
        
        // Handle row selection
        searchResultsTableView.rx.modelSelected(TwitterUser.self)
            .subscribe(onNext: { [weak self] user in
                self?.handleUserSelection(user)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            searchResultsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            searchResultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchResultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchResultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func handleUserSelection(_ user: TwitterUser) {
        let profileViewModel = ProfileViewModel(user: user)
        let vc = ProfileViewController(viewModel: profileViewModel)
        present(vc, animated: true)
    }
}
