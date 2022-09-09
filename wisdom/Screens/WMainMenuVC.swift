//
//  ViewController.swift
//  wisdom
//
//  Created by cipher on 09.09.2022.
//

import UIKit

class WMainMenuVC: UIViewController {

    private let TitleFontSize: CGFloat = 30
    private let SpaceBetween: CGFloat = 30
    
    public var coreDataService: WCoreDataServiceProtocol?

    override func loadView() {
        super.loadView()
        
        createLayout()
    }
    
    // MARK: - Handlers -

    @objc
    private func textsListButtonTapped(sender: UIButton) {
    }
    
    @objc
    private func settingsButtonTapped(sender: UIButton) {
    }

    // MARK: - Routine -

    private func createLayout() {
        view.backgroundColor = .wisdom_white()
        
        let titleContainerView = UIView(frame: .zero)
        titleContainerView.translatesAutoresizingMaskIntoConstraints = false
        titleContainerView.backgroundColor = .clear
        view.addSubview(titleContainerView)
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .wisdom_flexRegular(TitleFontSize)
        titleLabel.text = "MainMenuTitle".local.uppercased()
        titleLabel.textAlignment = .center
        titleContainerView.addSubview(titleLabel)

        let buttonsContainer = UIView(frame: .zero)
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainer.backgroundColor = .clear
        view.addSubview(buttonsContainer)

        let textsListButton = UIButton.wisdom_createOvalButton()
        textsListButton.setTitle("MainMenuTextsListItem".local.uppercased(), for: .normal)
        textsListButton.addTarget(self, action: #selector(textsListButtonTapped(sender:)), for: .touchUpInside)
        buttonsContainer.addSubview(textsListButton)

        let settingsButton = UIButton.wisdom_createOvalButton()
        settingsButton.setTitle("MainMenuSettingsItem".local.uppercased(), for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped(sender:)), for: .touchUpInside)
        buttonsContainer.addSubview(settingsButton)

        let buttonsHeight: CGFloat = OvalButtonsWidth / 4.0
        NSLayoutConstraint.activate([
            titleContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            titleContainerView.bottomAnchor.constraint(equalTo: buttonsContainer.topAnchor),

            titleLabel.centerYAnchor.constraint(equalTo: titleContainerView.safeAreaLayoutGuide.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleContainerView.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleContainerView.safeAreaLayoutGuide.trailingAnchor),

            buttonsContainer.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            buttonsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsContainer.widthAnchor.constraint(equalToConstant: OvalButtonsWidth),
            buttonsContainer.heightAnchor.constraint(equalToConstant: 4.0 * buttonsHeight + 3.0 * SpaceBetween),
            
            textsListButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            textsListButton.centerXAnchor.constraint(equalTo: buttonsContainer.centerXAnchor),
            textsListButton.widthAnchor.constraint(equalToConstant: OvalButtonsWidth),
            textsListButton.heightAnchor.constraint(equalToConstant: buttonsHeight),

            settingsButton.topAnchor.constraint(equalTo: textsListButton.bottomAnchor, constant: SpaceBetween),
            settingsButton.centerXAnchor.constraint(equalTo: buttonsContainer.centerXAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: OvalButtonsWidth),
            settingsButton.heightAnchor.constraint(equalToConstant: buttonsHeight),
        ])
    }
}

