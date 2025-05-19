import UIKit
import ShadowImageButton

class HistoryController: BaseController {
    
    private enum Constants {
        static let shadowRadius: CGFloat = 14.7
        static let shadowOffset = CGSize(width: 0, height: 4)
        static let shadowOpacity: Float = 0.5
        static let buttonCornerRadius: CGFloat = 18
    }
    
    private let tableView = UITableView()
    private let navigationTitle = UILabel()
    
    private lazy var connectionImageView = UIImageView(image: UIImage(named: "emptyHistory")).apply {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var connectionTitleLabel = UILabel().apply {
        $0.font = .font(weight: .bold, size: 22)
        $0.text = "It looks empty here".localized
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var connectionSubtitleLabel = UILabel().apply {
        $0.font = .font(weight: .medium, size: 16)
        $0.textColor = UIColor.init(hex: "ADACB8")
        $0.text = "Plug in your TV to unlock these apps".localized
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var connectionStackView = UIStackView(arrangedSubviews: [
        connectionTitleLabel,
        connectionSubtitleLabel
    ]).apply {
        $0.axis = .vertical
        $0.spacing = 9
    }
    
    private lazy var connectButton = ShadowImageButton().apply {
        $0.configure(
            buttonConfig: .init(
                title: "Add document".localized,
                font: .font(weight: .bold, size: 18),
                textColor: .white,
                image: nil
            ),
            backgroundImageConfig: .init(
                image: UIImage(named: "settingsPremiumBackground"),
                cornerRadius: Constants.buttonCornerRadius,
                shadowConfig: .init(
                    color: UIColor(hex: "0044FF"),
                    opacity: Constants.shadowOpacity,
                    offset: Constants.shadowOffset,
                    radius: Constants.shadowRadius
                )
            )
        )
        $0.action = { [weak self] in self?.openImport() }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        configureNavigation()
    }
    
    private func configureViewHierarchy() {
        
        view.addSubviews(
            connectionImageView,
            connectionStackView,
            connectButton
        )
        
        connectionImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-100)
            $0.horizontalEdges.equalToSuperview()
        }
        
        connectionStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(connectionImageView.snp.bottom).inset(-21)
            $0.horizontalEdges.equalToSuperview().inset(50)
        }
        
        connectButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(84)
            $0.height.equalTo(56)
            $0.top.equalTo(connectionStackView.snp.bottom).inset(-28)
        }
        
        //        view.addSubview(tableView)
        //        tableView.snp.makeConstraints {
        //            $0.top.equalTo(topView.snp.bottom)
        //            $0.left.right.bottom.equalToSuperview()
        //        }
        //
        //        tableView.register(
        //            PremiumCell.self,
        //            forCellReuseIdentifier: PremiumCell.reuseID
        //        )
        //        tableView.register(
        //            BaseCell.self,
        //            forCellReuseIdentifier: BaseCell.reuseID
        //        )
        //
        //        tableView.delegate = self
        //        tableView.dataSource = self
        //        tableView.backgroundColor = .clear
        //        tableView.separatorStyle = .none
        //        tableView.contentInset.top = 10
        //        tableView.contentInset.bottom = 100
        //        tableView.showsVerticalScrollIndicator = false
    }
    
    private func configureNavigation() {
        navigationTitle.text = "History".localized
        navigationTitle.font = .font(weight: .bold, size: 28)
        configurNavigation(leftView: navigationTitle)
    }
    
    @objc private func openImport() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
