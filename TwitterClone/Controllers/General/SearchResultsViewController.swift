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
    
    // Use BehaviorRelay to store the users list reactively
    private let users = BehaviorRelay<[TwitterUser]>(value: [])
    
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
        bindTableView()
    }
    
    func update(users: [TwitterUser]) {
        self.users.accept(users)
    }
    
    private func bindTableView() {
        // Bind users to the table view
        users
            .bind(to: searchResultsTableView.rx.items(cellIdentifier: UserTableViewCell.identifier, cellType: UserTableViewCell.self)) { row, user, cell in
                cell.configure(with: user)
            }
            .disposed(by: disposeBag)
        
        // Handle row selection
        searchResultsTableView.rx
            .modelSelected(TwitterUser.self)
            .subscribe(onNext: { [weak self] user in
                guard let self = self else { return }
                let profileViewModel = ProfileViewModel(user: user)
                let vc = ProfileViewController(viewModel: profileViewModel)
                self.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        // Deselect row after selection
        searchResultsTableView.rx
            .itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.searchResultsTableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureConstraints() {
        
        let searchResultsTableViewConstraints = [
            searchResultsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            searchResultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchResultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchResultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(searchResultsTableViewConstraints)
    }
}

extension SearchResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }
}
