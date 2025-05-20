import UIKit
import PremiumManager
import WebKit
import SnapKit
import PDFKit
import ShadowImageButton

final class BrowserPrintController: UIViewController {

    private let webView = WKWebView()
    private let urlTextField = UITextField()
    private let backButton = UIButton()
    private let forwardButton = UIButton()
    private let reloadButton = UIButton()
    
    private lazy var printButton = ShadowImageButton().apply {
        $0.configure(
            buttonConfig: .init(
                title: "Print".localized,
                font: .font(weight: .bold, size: 16),
                textColor: .white,
                image: nil
            ),
            backgroundImageConfig: .init(
                image: UIImage(named: "settingsPremiumBackground"),
                cornerRadius: 12.0,
                shadowConfig: .init(
                    color: UIColor(hex: "0044FF"),
                    opacity: 0.5,
                    offset: CGSize(width: 0, height: 4),
                    radius: 12
                )
            )
        )
        $0.action = { [weak self] in self?.printCurrentPage() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadHomePage()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#0A0F2E")
        setupNavigation()
        setupSearchField()
        setupWebView()
        setupBottomBar()
    }

    private func setupNavigation() {
        let titleLabel = UILabel()
        titleLabel.text = "Browser".localized
        titleLabel.font = .font(weight: .bold, size: 20)
        titleLabel.textColor = .white

        let back = UIButton(type: .system)
        back.setImage(UIImage(named: "left"), for: .normal)
        back.tintColor = .white
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        view.addSubview(back)
        view.addSubview(titleLabel)

        back.snp.makeConstraints {
            $0.left.equalToSuperview().inset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(19)
            $0.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(back)
            $0.centerX.equalToSuperview()
        }
    }

    private func setupSearchField() {
        urlTextField.text = "Google.com"
        urlTextField.backgroundColor = .white.withAlphaComponent(0.1)
        urlTextField.textColor = .white
        urlTextField.font = .font(weight: .medium, size: 18)
        urlTextField.layer.cornerRadius = 12
        urlTextField.clearButtonMode = .whileEditing
        urlTextField.returnKeyType = .go
        urlTextField.delegate = self

        let icon = UIImageView(image: UIImage(named: "search"))
        icon.contentMode = .center
        icon.tintColor = .white

        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 54, height: 24))
        icon.frame = CGRect(x: 17, y: 0, width: 24, height: 24)
        icon.center.y = iconContainer.center.y
        iconContainer.addSubview(icon)

        urlTextField.leftView = iconContainer
        urlTextField.leftViewMode = .always

        urlTextField.leftViewMode = .always
        urlTextField.borderStyle = .none

        view.addSubview(urlTextField)

        urlTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(71)
            $0.left.right.equalToSuperview().inset(25)
            $0.height.equalTo(56)
        }
    }

    private func setupWebView() {
        webView.navigationDelegate = self
        webView.backgroundColor = .white
        view.addSubview(webView)

        webView.snp.makeConstraints {
            $0.top.equalTo(urlTextField.snp.bottom).offset(24)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().inset(104)
        }
    }
    
    private func updateNavigationButtons() {
        let canGoBack = webView.canGoBack
        let canGoForward = webView.canGoForward

        backButton.isEnabled = canGoBack
        forwardButton.isEnabled = canGoForward

        let backImage = UIImage(named: canGoBack ? "circleBackActive" : "circleBack")
        let forwardImage = UIImage(named: canGoForward ? "circleForwardActive" : "circleForward")

        backButton.setImage(backImage, for: .normal)
        forwardButton.setImage(forwardImage, for: .normal)
    }

    private func setupBottomBar() {
        let bar = UIView()
        bar.backgroundColor = UIColor(hex: "#10163A")
        bar.clipsToBounds = true

        view.addSubview(bar)

        bar.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(104)
        }
        reloadButton.setImage(UIImage(named: "reload"), for: .normal)
        reloadButton.addTarget(self, action: #selector(reloadPage), for: .touchUpInside)

        backButton.setImage(UIImage(named: "circleBack"), for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        forwardButton.setImage(UIImage(named: "circleForward"), for: .normal)
        forwardButton.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        
        let centerStack = UIStackView(arrangedSubviews: [backButton, forwardButton])
        centerStack.axis = .horizontal
        centerStack.spacing = 21
        centerStack.alignment = .center
        centerStack.distribution = .equalSpacing

        bar.addSubview(centerStack)

        centerStack.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(26)
        }
        
        bar.addSubview(printButton)

        printButton.snp.makeConstraints {
            $0.centerY.equalTo(centerStack)
            $0.width.equalTo(90)
            $0.height.equalTo(35)
            $0.right.equalToSuperview().inset(25)
        }
        
        bar.addSubview(reloadButton)
        
        reloadButton.snp.makeConstraints {
            $0.centerY.equalTo(centerStack)
            $0.width.equalTo(27)
            $0.height.equalTo(27)
            $0.left.equalToSuperview().inset(34)
        }
    }

    // MARK: - Actions

    @objc private func didTapBack() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss(animated: false)
    }

    @objc private func reloadPage() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        webView.reload()
    }

    @objc private func goBack() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if webView.canGoBack {
            webView.goBack()
        }
    }

    @objc private func goForward() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if webView.canGoForward {
            webView.goForward()
        }
    }

    @objc private func printCurrentPage() {
        
        guard PremiumManager.shared.isPremium.value else {
            PaywallManager.shared.showPaywall()
            return
        }
        
        if Storage.shared.buttonsTapNumber > 4, !Storage.shared.wasReviewScreen {
            Storage.shared.wasReviewScreen = true
            UIApplication.topViewController()?.presentCrossDissolve(vc: ReviewController())
        }
        Storage.shared.buttonsTapNumber += 1
        webView.createPDF { [weak self] pdfData in
            guard let self, let pdfData else { return }

            do {
                let fileName = UUID().uuidString
                let filePath = try DocumentFileManager.shared.savePDF(data: pdfData, withName: fileName)

                let doc = Document(
                    id: fileName,
                    name: self.webView.title ?? "Web page",
                    filePath: filePath,
                    dateAdded: Date(),
                    lastModified: Date(),
                    source: .browser
                )

                RealmManager.shared.saveDocument(doc) {}

                let url = DocumentFileManager.shared.fileURL(for: filePath)
                let printController = UIPrintInteractionController.shared
                printController.printingItem = url
                printController.present(animated: true)

            } catch {}
        }
    }

    private func loadHomePage() {
        let url = URL(string: "https://www.google.com")!
        webView.load(URLRequest(url: url))
    }
}

// MARK: - UITextFieldDelegate

extension BrowserPrintController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text,
              let url = URL(string: text.hasPrefix("http") ? text : "https://\(text)") else {
            return false
        }

        webView.load(URLRequest(url: url))
        textField.resignFirstResponder()
        return true
    }
}

extension BrowserPrintController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateNavigationButtons()
        urlTextField.text = webView.url?.absoluteString
    }
}
