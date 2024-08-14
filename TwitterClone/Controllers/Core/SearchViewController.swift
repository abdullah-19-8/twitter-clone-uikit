//
//  SearchViewController.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 6/26/24.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: SearchResultsViewController())
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.placeholder = "Search with @username"
        return searchController
    }()
    
    private let promptLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Search for users and get connected"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .placeholderText
        return label
    }()
    
    private let disposeBag = DisposeBag()
    
    let viewModel: SearchViewModel
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(promptLabel)
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        
        configureConstraints()
        bindViewModel()
    }
    
    private func configureConstraints() {
        let promptLabelConstraints = [
            promptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promptLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            promptLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        NSLayoutConstraint.activate(promptLabelConstraints)
    }
    
    private func bindViewModel() {
        // Bind search bar text to view model search
        searchController.searchBar.rx.text
            .orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] query in
                self?.viewModel.search(with: query)
            })
            .disposed(by: disposeBag)
        
        // Bind view model users to search results view controller
        viewModel.users
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] users in
                guard let resultsViewController = self?.searchController.searchResultsController as? SearchResultsViewController else { return }
                resultsViewController.update(users: users)
            })
            .disposed(by: disposeBag)
        
        // Handle errors
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                self?.presentAlert(with: errorMessage)
            })
            .disposed(by: disposeBag)
    }
    
    private func presentAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // No longer needed as we use RxSwift to handle updates
    }
}
