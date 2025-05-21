import UIKit
import Foundation

protocol BaseCellDelegate: AnyObject {
    func baseCellDidTapMenu(_ cell: BaseCell)
}

final class BaseCell: UITableViewCell {

    static let reuseID = "BaseCell"
    
    weak var delegate: BaseCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        setupActions()
    }

    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(menuTapped))
        rightImageView.isUserInteractionEnabled = true
        rightImageView.addGestureRecognizer(tapGesture)
    }

    @objc private func menuTapped() {
        delegate?.baseCellDidTapMenu(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leftImageView.image = nil
        titleLabel.text = nil
        documentNameLabel.text = nil
        dateLabel.text = nil
        titleLabel.isHidden = false
        documentStack.isHidden = true
    }

    private lazy var customBackgroundView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "baseCellBackground"))
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()

    private let leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let rightImageView: UIImageView = {
        let imageView = UIImageView(image: .init(named: "menu"))
        imageView.isHidden = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .bold, size: 18)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private let documentNameLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .bold, size: 18)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .medium, size: 14)
        label.textColor = UIColor(hex: "ADACB8")
        return label
    }()

    private lazy var documentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [documentNameLabel, dateLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fillEqually
        stack.spacing = 2
        return stack
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(customBackgroundView)

        customBackgroundView.addSubview(leftImageView)
        customBackgroundView.addSubview(documentStack)
        customBackgroundView.addSubview(rightImageView)
        customBackgroundView.addSubview(titleLabel)

        customBackgroundView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(25)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().inset(17)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(61)
            make.right.equalToSuperview().inset(22)
            make.centerY.equalToSuperview()
        }

        leftImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(17)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(26)
        }
        
        documentStack.snp.makeConstraints {
            $0.left.equalTo(leftImageView.snp.right).offset(16)
            $0.centerY.equalToSuperview()
            $0.right.lessThanOrEqualTo(rightImageView.snp.left).offset(-16)
        }

        rightImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(16)
            $0.width.height.equalTo(24)
        }
    }
    
    func configure(type: SettingsOption) {
        
        documentStack.isHidden = true
        titleLabel.isHidden = false
        
        titleLabel.text = type.displayTitle
        leftImageView.image = type.iconAsset
    }
    
    func configure(type: ImportCellType) {
        
        rightImageView.image = .init(named: "arrow")
        
        documentStack.isHidden = true
        titleLabel.isHidden = false
        
        titleLabel.text = type.displayTitle
        leftImageView.image = type.iconAsset
        
        leftImageView.snp.updateConstraints { make in
            make.left.equalToSuperview().inset(9)
            make.height.width.equalTo(60)
        }
        
        titleLabel.snp.updateConstraints { make in
            make.left.equalToSuperview().inset(86)
        }
        
        rightImageView.isHidden = false
    }
}

extension BaseCell {
    func configureForDocument(document: Document) {
        
        titleLabel.isHidden = true
        documentStack.isHidden = false
        
        documentNameLabel.text = document.name
        dateLabel.text = DateFormatter.displayDate.string(from: document.dateAdded)
        rightImageView.isHidden = false
        rightImageView.image = UIImage(named: "menu")

        leftImageView.snp.updateConstraints {
            $0.left.equalToSuperview().inset(10)
            $0.height.width.equalTo(60)
        }
        
        titleLabel.snp.updateConstraints {
            $0.left.equalToSuperview().inset(86)
        }
        
        leftImageView.layer.cornerRadius = 15
        leftImageView.layer.masksToBounds = true
        leftImageView.contentMode = .scaleAspectFill
        leftImageView.clipsToBounds = true
        leftImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        leftImageView.layer.borderWidth = 1
        
        if let preview = PDFPreviewGenerator.shared.previewImage(for: document.filePath) {
            leftImageView.image = preview
        }
    }
}
