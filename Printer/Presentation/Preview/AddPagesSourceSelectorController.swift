import UIKit
import SnapKit
import CustomBlurEffectView
import Utilities

enum AddPageSource {
    case camera
    case gallery
    case files
}

protocol AddPagesSourceSelectorDelegate: AnyObject {
    func addPagesSourceSelectorDidSelect(_ source: AddPageSource)
}

final class AddPagesSourceSelectorController: UIViewController {
    
    weak var delegate: AddPagesSourceSelectorDelegate?
    
    private enum Constants {
        static let blurRadius: CGFloat = 3
        static let blurColor = UIColor(hex: "171313")
        static let blurAlpha: CGFloat = 0.3
        
        static let contentCornerRadius: CGFloat = 30
        static let contentHeight: CGFloat = 393
        static let contentBackground = UIColor(hex: "0F1C35")
        
        static let titleFontSize: CGFloat = 20
        static let horizontalInset: CGFloat = 24
        
        static let buttonHeight: CGFloat = 69
        static let buttonSpacing: CGFloat = 13
        
        static let closeButtonSize: CGFloat = 31
        static let closeButtonTop: CGFloat = 24
        static let closeButtonRight: CGFloat = 24
    }
    
    // MARK: - UI
    
    private let blurView = CustomBlurEffectView().apply {
        $0.blurRadius = Constants.blurRadius
        $0.colorTint = Constants.blurColor
        $0.colorTintAlpha = Constants.blurAlpha
    }

    private let contentView = UIView().apply {
        $0.backgroundColor = Constants.contentBackground
        $0.layer.cornerRadius = Constants.contentCornerRadius
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private let titleLabel = UILabel().apply {
        $0.text = "Import from".localized
        $0.textColor = .white
        $0.font = .font(weight: .bold, size: Constants.titleFontSize)
        $0.textAlignment = .center
    }

    private lazy var cameraButton = makeSourceButton(title: "Camera", icon: UIImage(named: "cameraOption"))
    private lazy var galleryButton = makeSourceButton(title: "Gallery", icon: UIImage(named: "galleryOption"))
    private lazy var filesButton = makeSourceButton(title: "Files", icon: UIImage(named: "filesOption"))

    private lazy var closeButton = UIButton().apply {
        $0.setImage(UIImage(named: "close"), for: .normal)
        $0.addTarget(self, action: #selector(close), for: .touchUpInside)
    }

    private lazy var stackView = UIStackView(arrangedSubviews: [
        cameraButton, galleryButton, filesButton
    ]).apply {
        $0.axis = .vertical
        $0.spacing = Constants.buttonSpacing
        $0.distribution = .fillEqually
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
         super.viewDidLoad()
         setupView()
         setupLayout()
         setupActions()
     }

     private func setupActions() {
         cameraButton.addTarget(self, action: #selector(selectCamera), for: .touchUpInside)
         galleryButton.addTarget(self, action: #selector(selectGallery), for: .touchUpInside)
         filesButton.addTarget(self, action: #selector(selectFiles), for: .touchUpInside)
     }

     @objc private func selectCamera() {
         dismiss(animated: true) {
             self.delegate?.addPagesSourceSelectorDidSelect(.camera)
         }
     }

     @objc private func selectGallery() {
         dismiss(animated: true) {
             self.delegate?.addPagesSourceSelectorDidSelect(.gallery)
         }
     }

     @objc private func selectFiles() {
         dismiss(animated: true) {
             self.delegate?.addPagesSourceSelectorDidSelect(.files)
         }
     }

    // MARK: - Setup

    private func setupView() {
        view.addSubview(blurView)
        blurView.addSubview(contentView)
        contentView.addSubviews(titleLabel, closeButton, stackView)
    }

    private func setupLayout() {
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }

        contentView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(Constants.contentHeight)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(58)
            $0.centerX.equalToSuperview()
        }

        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(Constants.closeButtonTop)
            $0.trailing.equalToSuperview().inset(Constants.closeButtonRight)
            $0.width.height.equalTo(Constants.closeButtonSize)
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(26)
            $0.left.right.equalToSuperview().inset(Constants.horizontalInset)
            $0.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(24)
        }

        [cameraButton, galleryButton, filesButton].forEach {
            $0.layer.cornerRadius = 18
            $0.backgroundColor = UIColor(hex: "1A1F3C")
            
            $0.snp.makeConstraints { make in
                make.height.equalTo(Constants.buttonHeight)
            }
        }
    }

    // MARK: - Helpers

    private func makeSourceButton(title: String, icon: UIImage?) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("  \(title)", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .font(weight: .bold, size: 18)
        button.setBackgroundImage(.init(named: "baseCellBackground"), for: .normal)
        button.setImage(icon, for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = .init(top: 0, left: 41, bottom: 0, right: 18)
        button.imageEdgeInsets = .init(top: 0, left: -18, bottom: 0, right: 0)
        button.imageView?.contentMode = .scaleAspectFit
        button.clipsToBounds = true
        return button
    }

    // MARK: - Actions

    @objc private func close() {
        dismiss(animated: true)
    }
}
