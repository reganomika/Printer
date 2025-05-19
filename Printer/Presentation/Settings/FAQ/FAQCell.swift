import UIKit
import SnapKit
import Utilities

final class FAQCell: UITableViewCell {
    
    static let identifier = "FAQCell"
    
    private let rightImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var customBackgroundView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "baseCellBackground"))
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .medium, size: 18)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .medium, size: 14)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(customBackgroundView)
        contentView.addSubview(rightImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        customBackgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(25)
            make.top.bottom.equalToSuperview().inset(12)
        }
        
        rightImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(43)
            make.centerY.equalTo(titleLabel)
            make.height.width.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(47)
            make.right.equalToSuperview().inset(82)
            make.top.equalToSuperview().inset(30)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(47)
            make.right.equalToSuperview().inset(35)
            make.top.equalTo(titleLabel.snp.bottom).inset(-10)
            make.bottom.equalToSuperview().inset(21)
        }
    }
    
    func configure(model: FAQModel, isExpanded: Bool) {

        titleLabel.text = model.title
        
        subtitleLabel.isHidden = !isExpanded
        
        let subtitleString: String
        
        if isExpanded {
            subtitleString = model.subtitle
        } else {
            subtitleString = ""
        }
        
        subtitleLabel.text = subtitleString.localized
        
        rightImageView.image = isExpanded ? UIImage(named: "arrowUp") : UIImage(named: "arrow")
    }
}
