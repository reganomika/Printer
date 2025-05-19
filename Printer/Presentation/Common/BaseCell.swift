import Utilities
import UIKit
import SnapKit

final class BaseCell: UITableViewCell {
    
    static let reuseID = "BaseCell"
    
    private lazy var customBackgroundView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "baseCellBackground"))
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let leftImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let rightImageView: UIImageView = {
        let imageView = UIImageView(image: .init(named: "down"))
        imageView.isHidden = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .medium, size: 18)
        label.textColor = .white
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .bold, size: 18)
        label.textColor = .white
        label.isHidden = true
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
        
        customBackgroundView.addSubview(leftImageView)
        customBackgroundView.addSubview(titleLabel)
        customBackgroundView.addSubview(valueLabel)
        customBackgroundView.addSubview(rightImageView)
        
        leftImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(17)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(26)
        }
        
        customBackgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(25)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(13)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(61)
            make.right.equalToSuperview().inset(22)
            make.centerY.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(53)
            make.centerY.equalToSuperview()
        }
        
        rightImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.height.width.equalTo(24)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(type: SettingsOption) {
        titleLabel.text = type.displayTitle
        leftImageView.image = type.iconAsset
    }
    
    func configure(value: String, isSelected: Bool) {
        titleLabel.font = .font(weight: .bold, size: 18)
        titleLabel.text = value
        rightImageView.image = isSelected ? UIImage(named: "selection") : nil
        rightImageView.isHidden = !isSelected
        
        titleLabel.snp.updateConstraints { make in
            make.left.equalToSuperview().inset(21)
        }
        
        if isSelected {
            rightImageView.snp.updateConstraints { make in
                make.right.equalToSuperview().inset(18)
                make.height.width.equalTo(33)
            }
        }
    }
}
