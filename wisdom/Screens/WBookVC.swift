//
//  WBookVC.swift
//  wisdom
//
//  Created by cipher on 12.11.2023.
//

import UIKit

class WBookVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var book: WBook {
        didSet {
            tableView.reloadData()
        }
    }
    private let tableView = UITableView(frame: .zero)
    
    init(book: WBook) {
        self.book = book
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
    }

    // MARK: - UICollectionViewDataSource -

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        UIListContentConfiguration
        switch indexPath.row {
        case 0:
            newCell.deta
        case 1:
        case 2:
        }
        
        return newCell
    }

    // MARK: - Routine -

    private func createLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
}
