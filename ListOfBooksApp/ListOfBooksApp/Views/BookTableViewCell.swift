
import UIKit
import SnapKit

/// Custom UITableViewCell for displaying book information.
class BookTableViewCell: UITableViewCell {
    
    static let identifier = "BookTableViewCell"
    
    /// Image view for displaying a book icon.
    private let bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "book.fill")
        imageView.tintColor = UIColor.systemPink
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// Label for displaying the book title.
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    /// Label for displaying the author's name.
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    /// Initializes the cell with the given style and reuse identifier.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Configures the layout of the cell's subviews using SnapKit.
    private func setupViews() {
        contentView.addSubview(bookImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)

        let padding: CGFloat = 15

        bookImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(padding)
            make.centerY.equalToSuperview()
            make.width.equalTo(40).priority(.required)
            make.height.equalTo(40).priority(.required)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(bookImageView.snp.trailing).offset(padding)
            make.top.equalToSuperview().offset(10)
            make.trailing.lessThanOrEqualToSuperview().offset(-padding)
        }

        authorLabel.snp.makeConstraints { make in
            make.leading.equalTo(bookImageView.snp.trailing).offset(padding)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.trailing.lessThanOrEqualToSuperview().offset(-padding)
            make.bottom.equalToSuperview().offset(-10).priority(.low)
        }
    }
    
    /// Configures the cell with book data.
    func configure(with item: ItemModel) {
        let components = item.title.split(separator: ":")
        if components.count == 2 {
            titleLabel.text = components[0].trimmingCharacters(in: .whitespaces)
            authorLabel.text = components[1].trimmingCharacters(in: .whitespaces)
        } else {
            titleLabel.text = item.title
            authorLabel.text = "Unknown Author"
        }
        updateSelectionState(isSelected: item.isSelected)
    }
    
    /// Updates the cell's appearance based on selection state.
    func updateSelectionState(isSelected: Bool) {
        contentView.backgroundColor = isSelected ? UIColor.lightGray.withAlphaComponent(0.5) : UIColor.white
    }
}
