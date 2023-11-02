//
//  ViewController.swift
//  wisdom
//
//  Created by cipher on 09.09.2022.
//

import UIKit

class WLibraryVC: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private let itemsPerRow: CGFloat = 3
    private let minimumItemSpacing: CGFloat = 8
    private let sectionInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 20.0, right: 16.0)

    private let activityIndicatorView = WActivityIndicatorView(frame: .zero)
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var booksService: WBooksServiceProtocol
    private var booksList = [WBook]()
    
    init(booksService: WBooksServiceProtocol, booksList: [WBook] = [WBook]()) {
        self.booksService = booksService
        self.booksList = booksList
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        createLayout()
        updateBooksList()
        downloadBooksList()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout -
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left + sectionInsets.right + minimumItemSpacing * (itemsPerRow - 1)
        let availableWidth = collectionView.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell selected")
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.clear
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.white
    }
    
    // MARK: - UICollectionViewDataSource -
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return booksList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WBookCell.reuseID,
                                                            for: indexPath) as? WBookCell else {
            fatalError("Wrong cell")
        }
        
        cell.configureCell(booksList[indexPath.row])
        
        return cell
    }
    
    // MARK: - Routine -
    
    private func refreshBooksList(_ newBooksList: [WBook]?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            guard let newBooksList = newBooksList else {
                return
            }
            self.booksList = newBooksList
            self.collectionView.reloadData()
        }
    }
    
    private func updateBooksList() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicatorView.startAnimating()
        }
        booksService.fetchBooksList(nil) { [weak self] fetchedResult in
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicatorView.stopAnimating()
            }
            switch fetchedResult {
            case .success(let fetchedBooksList):
                self?.refreshBooksList(fetchedBooksList)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func downloadBooksList() {
        Task { [weak self] in
            guard let self = self else { return }
            let downloadedResult = await self.booksService.downloadBooksList()
            switch downloadedResult {
            case .success(let downloadedBooksList):
                self.booksService.saveBooksList(downloadedBooksList) {
                    self.updateBooksList()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func createLayout() {
        view.backgroundColor = .wisdom_white()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WBookCell.self, forCellWithReuseIdentifier: WBookCell.reuseID)
        view.addSubview(collectionView)
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicatorView.topAnchor.constraint(equalTo: view.topAnchor),
            activityIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

