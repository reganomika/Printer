import UIKit
import SnapKit
import Utilities

protocol TabBarViewDelegate: AnyObject {
    func tabBarView(_ tabBarView: TabBarView, didSelectItemAt index: Int)
}

enum TabBarViewItemType {
    case tabItem(selectedImage: UIImage?, unselectedImage: UIImage?, String)
}

final class TabBarView: UIView {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 0
        return stackView
    }()

    weak var delegate: TabBarViewDelegate?
    private var tabButtons: [UIView] = []
    
    private let items: [TabBarViewItemType] = [
        .tabItem(
            selectedImage: UIImage(named: "importTabSelected"),
            unselectedImage: UIImage(named: "importTabUnselected"),
            "import".localized
        ),
        .tabItem(
            selectedImage: UIImage(named: "historyTabSelected"),
            unselectedImage: UIImage(named: "historyTabUnselected"),
            "history".localized
        ),
        .tabItem(
            selectedImage: UIImage(named: "settingsTabSelected"),
            unselectedImage: UIImage(named: "settingsTabUnselected"),
            "settings".localized
        )
    ]

    init() {
        super.init(frame: .zero)
        
        backgroundColor = .white.withAlphaComponent(0.08)
        layer.cornerRadius = 18
        
        setupTabBarButtons()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTabBarButtons() {
        for (index, item) in items.enumerated() {
            if case let .tabItem(selectedImage, unselectedImage, title) = item {
                let button = createTabButton(
                    selectedImage: selectedImage,
                    unselectedImage: unselectedImage,
                    title: title,
                    tag: index
                )
                stackView.addArrangedSubview(button)
                tabButtons.append(button)
            }
        }
        updateSelectedButton(at: 0)
    }
    
    private func createTabButton(
        selectedImage: UIImage?,
        unselectedImage: UIImage?,
        title: String,
        tag: Int
    ) -> UIView {
        let container = UIView()
        container.tag = tag
        
        let imageView = UIImageView(image: unselectedImage)
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 100
        
        let label = GradientLabel()
        label.label.text = title
        label.label.font = .font(weight: .medium, size: 14)
        label.tag = 101
        
        container.addSubview(imageView)
        container.addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tabButtonTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        
        return container
    }

    private func setupLayout() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc private func tabButtonTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedIndex = sender.view?.tag else { return }
        updateSelectedButton(at: selectedIndex)
        delegate?.tabBarView(self, didSelectItemAt: selectedIndex)
    }

    private func updateSelectedButton(at index: Int) {
        for (i, item) in items.enumerated() {
            guard case let .tabItem(selectedImage, unselectedImage, _) = item,
                  i < tabButtons.count else { continue }
            
            let button = tabButtons[i]
            let imageView = button.viewWithTag(100) as? UIImageView
            let label = button.viewWithTag(101) as? GradientLabel
           
            let isSelected = index == i
            
//            label?.label.font = .font(weight: isSelected ? .bold : .medium, size: 14.0)
            
            imageView?.image = isSelected ? selectedImage : unselectedImage
            if isSelected {
                label?.setLabelColor()
            } else {
                label?.setLabelColor(plainColor: UIColor(hex: "ADACB8"))
            }
        }
    }
}
