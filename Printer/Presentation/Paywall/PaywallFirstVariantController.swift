import UIKit
import PremiumManager
import StoreKit
import SafariServices
import SnapKit
import RxSwift
import ShadowImageButton
import Utilities
import ApphudSDK

class PaywallFirstVariantController: OnboardingController {
    
    private lazy var topProduct = premiumManager.products.value.first
    private lazy var bottomProduct = premiumManager.products.value.last
    
    var productToPurchase: ApphudProduct?
    
    lazy var topOptionView: PaywallOptionView = {
        let view = PaywallOptionView()
        
        var title = topProduct?.duration?.longDescription.capitalized ?? "-"
        var rightTitle = "-"
        var subtitle: String?
        
        if let duration = product?.duration,
           let symbol = product?.currency,
           let price = product?.priceNumber {
            
            let days: Double
            switch duration {
            case .week:
                days = 7
            case .month:
                days = 30
            case .year:
                days = 365
            case .quarter:
                days = 90
            default:
                days = 1
            }
            
            let nonTrialDailyPrice = (price / days) * 7
                        
            if duration == .week {
                subtitle = nil
                rightTitle = "\(symbol)\(String(format: "%.2f", price))/\(duration.rawValue.localized)"
            } else {
                subtitle = "\(symbol)\(String(format: "%.2f", price))/\(duration.rawValue.localized)"
                rightTitle = "\(symbol)\(String(format: "%.2f", nonTrialDailyPrice))" + "/" + "week".localized.lowercased()
            }
        }
        
        view.configure(
            title: title,
            subtitle: subtitle,
            rightTitle: rightTitle,
            isSelected: false
        )
        view.add(target: self, action: #selector(topOptionTapped))
        return view
    }()
    
    lazy var bottomOptionView: PaywallOptionView = {
        let view = PaywallOptionView()
        
        var title = bottomProduct?.duration?.longDescription.capitalized ?? "-"
        var rightTitle = "-"
        var subtitle: String?
        
        if let duration = bottomProduct?.duration,
           let symbol = bottomProduct?.currency,
           let price = bottomProduct?.priceNumber {
            
            let days: Double
            switch duration {
            case .week:
                days = 7
            case .month:
                days = 30
            case .year:
                days = 365
            case .quarter:
                days = 90
            default:
                days = 1
            }
            
            let nonTrialDailyPrice = (price / days) * 7
            
            if duration == .week {
                subtitle = nil
                rightTitle = "\(symbol)\(String(format: "%.2f", price))/\(duration.rawValue.localized)"
            } else {
                subtitle = "\(symbol)\(String(format: "%.2f", price))/\(duration.rawValue.localized)"
                rightTitle = "\(symbol)\(String(format: "%.2f", nonTrialDailyPrice))" + "/" + "week".localized.lowercased()
            }
        }
        view.configure(
            title: title,
            subtitle: subtitle,
            rightTitle: rightTitle,
            isSelected: true
        )
        view.add(target: self, action: #selector(bottomOptionTapped))
        return view
    }()
    
    lazy var optionsStackView: UIStackView = {
        
        let stackView = UIStackView(arrangedSubviews: [topOptionView, bottomOptionView])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private let fourthButton = UIButton()
    
    public var customTitle: String = "" {
        didSet {
            updateTitle()
        }
    }
    
    public var customSubtitle: String = "" {
        didSet {
            subtitleLabel.attributedText = customSubtitle.attributedString(
                font: .font(weight: .medium, size: 16),
                aligment: .center,
                color: .init(hex: "ADACB8"),
                lineSpacing: 0,
                maxHeight: 20
            )
        }
    }
    
    private lazy var switchView: UISwitch = {
        let view = UISwitch()
        view.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        return view
    }()
    
    private lazy var switchLabel: UILabel = {
        let view = UILabel()
        view.font = .font(weight: .bold, size: 16)
        view.textColor = .white
        view.text = "Start free trial".localized
        return view
    }()
    
    lazy var switchStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [switchLabel, switchView])
        view.axis = .horizontal
        view.distribution = .equalSpacing
        return view
    }()
    
    let highlightedText: String = "Unlimited".localized
    
    private let isFromOnboarding: Bool
    
    private let premiumManager = PremiumManager.shared
    
    private lazy var product: ApphudProduct? = topProduct
    
    init(isFromOnboarding: Bool) {
        self.isFromOnboarding = isFromOnboarding
        super.init(
            model: OnboardingModel(image: UIImage(), title: "", higlitedTexts: [], subtitle: "", rating: false),
            coordinator: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        customTitle = "Air Printer Unlimited".localized
        customSubtitle = "Print without limits, experience faster processing, and files storage".localized
       
        imageView.image = UIImage(named: "paywall_1")
        
        view.addSubview(switchStackView)
        view.addSubview(optionsStackView)
        
        switchStackView.snp.makeConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).inset(-12)
            make.height.equalTo(31)
            make.left.right.equalToSuperview().inset(41)
        }
        
        optionsStackView.snp.makeConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).inset(-59)
            make.left.right.equalToSuperview().inset(26)
            make.height.equalTo(150)
        }
        
        topOptionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(69)
        }
        
        bottomOptionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(69)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imageView.snp.updateConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).inset(-209)
        }
    }
    
    override func setupButtons() {
        
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually
        bottomStackView.spacing = 16
        
        let newButton = createBottomButton(title: "Not now".localized)
        newButton.addTarget(self, action: #selector(closePaywall), for: .touchUpInside)
        
        let privacyButton = createBottomButton(title: "Privacy".localized)
        let restoreButton = createBottomButton(title: "Restore".localized)
        let termsButton = createBottomButton(title: "Terms".localized)
        
        privacyButton.addTarget(self, action: #selector(openPrivacy), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restore), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(openTerms), for: .touchUpInside)
        
        bottomStackView.addArrangedSubview(privacyButton)
        bottomStackView.addArrangedSubview(restoreButton)
        bottomStackView.addArrangedSubview(termsButton)
        bottomStackView.addArrangedSubview(newButton)
        
        view.addSubview(bottomStackView)
        
        bottomStackView.snp.remakeConstraints { make in
            make.top.equalTo(nextButton.snp.bottom).offset(21)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(18)
        }
    }
    
    private func updateTitle() {
        let attributedString = NSMutableAttributedString(attributedString: customTitle.attributedString(
            font: .font(weight: .bold, size: 28),
            aligment: .center,
            color: .white,
            lineSpacing: 5,
            maxHeight: 50
        ))
        
        if !highlightedText.isEmpty {
            let range = (customTitle as NSString).range(of: highlightedText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.init(hex: "00BFFF"), range: range)
        }
        
        titleLabel.attributedText = attributedString
    }
    
    @objc private func closePaywall() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        closeAction()
    }
                       
    @objc func switchChanged(_ sender: UISwitch) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        if topOptionView.isSelectedOption {
            bottomOptionTapped()
        } else {
            topOptionTapped()
        }
    }
    
    override func closeAction() {
        if isFromOnboarding {
            replaceRootViewController(with: TabBarController())
        } else {
            dismiss()
        }
    }
    
    override func nexAction() {
        premiumManager.purchase(product: product)
    }
    
    @objc func topOptionTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        productToPurchase = product
        topOptionView.isSelectedOption = true
        bottomOptionView.isSelectedOption = false
        switchView.isOn = true
    }
    
    @objc func bottomOptionTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        productToPurchase = bottomProduct
        topOptionView.isSelectedOption = false
        bottomOptionView.isSelectedOption = true
        switchView.isOn = false
    }
}
