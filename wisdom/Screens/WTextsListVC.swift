//
//  WTextsListVC.swift
//  wisdom
//
//  Created by cipher on 09.09.2022.
//

import UIKit

class WTextsListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    private let TitleFontSize: CGFloat = 20
    
    //  injections
    public var textsService: WTextsServiceProtocol = WTextsService(nil)
    
    private var textsList = [WText]()
    private let searchbar = UISearchBar(frame: .zero)
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    override func loadView() {
        super.loadView()
        
        createLayout()
        refreshTextsList()
    }
    
    // MARK: - UITableViewDataSource -
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = YDCatalogCell(style: .default, reuseIdentifier: nil)
        
        newCell.configureCell(assignAsana: textsList[indexPath.row])
        
        return newCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return YDCatalogCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return BackButtonSize
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    // MARK: - UITableViewDelegate -
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    // MARK: - Handlers -
    
    @objc
    private func backButtonTapped(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        refreshTextsList()
    }
    
    // MARK: - Routine -
    
    private func createLayout() {
        view.backgroundColor = .wisdom_white()
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .wisdom_flexRegular(TitleFontSize)
        titleLabel.text = "CatalogTitle".local.uppercased()
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        searchbar.translatesAutoresizingMaskIntoConstraints = false
        searchbar.searchBarStyle = .minimal
        searchbar.delegate = self
        view.addSubview(searchbar)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
        
        let backButton = UIButton.wisdom_createRoundBackButton(BackButtonSize)
        backButton.addTarget(self, action: #selector(backButtonTapped(sender:)), for: .touchUpInside)
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: BackButtonSize),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: BackButtonSize),
            backButton.widthAnchor.constraint(equalToConstant: BackButtonSize),
            backButton.heightAnchor.constraint(equalToConstant: BackButtonSize),
            
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            searchbar.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: BackButtonSize),
            searchbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: BackButtonSize),
            searchbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -BackButtonSize),

            tableView.topAnchor.constraint(equalTo: searchbar.bottomAnchor, constant: BackButtonSize),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func refreshTextsList() {
        textsService.fetchTexts(searchbar.text) { textsList in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.textsList = textsList ?? [WText]()
                self.tableView.reloadData()
            }
        }
    }
    
}

