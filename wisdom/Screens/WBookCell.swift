import UIKit

class WBookCell: UICollectionViewCell {
    
    static let reuseID = String(describing: WBookCell.self)

    private let AuthorFontSize: CGFloat = 10
    private let TitleFontSize: CGFloat = 14
    private let SideOffset: CGFloat = 2

    private var book = WBook(sanskrit: "", english: "", iast: "")
    private let titleLabel = UILabel(frame: .zero)
    private let authorLabel = UILabel(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        createLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateContentStyle()
    }
    
    func configureCell(_ assignBook: WBook) {
//        authorLabel.text = assignBook.author
//        titleLabel.text = assignBook.title
    }
    
    // MARK: - Routine -

    private func createLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
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

    private func updateContentStyle() {
        backgroundColor = .cyan
        clipsToBounds = true
        layer.cornerRadius = 4

        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = .clear
        titleLabel.font = .wisdom_flexRegular(TitleFontSize)
        
        authorLabel.numberOfLines = 0
        authorLabel.backgroundColor = .clear
        authorLabel.font = .wisdom_flexRegular(AuthorFontSize)
        authorLabel.textAlignment = .right
    }
    
}
