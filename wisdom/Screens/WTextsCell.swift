//
//  WTextsCell.swift
//  wisdom
//
//  Created by cipher on 09.09.2022.
//

import UIKit

class WTextsCell: UITableViewCell {
    
    private let SideOffset: CGFloat = 10
    private let AuthorFontSize: CGFloat = 34
    private let TitleFontSize: CGFloat = 14

    private var text = WText(author: "", title: "", year: 0)
    private let titleLabel = UILabel(frame: .zero)
    private let authorLabel = UILabel(frame: .zero)

    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        createLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configureCell(_ assignText: WText) {
        authorLabel.text = assignText.author
        titleLabel.text = assignText.title
    }
    
    // MARK: - Routine -

    private func createLayout() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = .clear
        titleLabel.font = .wisdom_flexRegular(TitleFontSize)
        contentView.addSubview(titleLabel)

        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.numberOfLines = 0
        authorLabel.backgroundColor = .clear
        authorLabel.font = .wisdom_flexRegular(AuthorFontSize)
        authorLabel.textAlignment = .right
        contentView.addSubview(authorLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: SideOffset),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: SideOffset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -SideOffset),

            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: SideOffset),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: SideOffset),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -SideOffset),
        ])
    }
    
}
