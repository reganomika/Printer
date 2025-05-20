import UIKit
import WebKit
import SnapKit
import PDFKit

final class BrowserPrintController: UIViewController {

    private let webView = WKWebView()
    private let urlTextField = UITextField()
    private let backButton = UIButton(type: .system)
    private let forwardButton = UIButton(type: .system)
    private let reloadButton = UIButton(type: .system)
    private let printButton = UIButton(type: .system)

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
        titleLabel.text = "Browser"
        titleLabel.font = .font(weight: .bold, size: 20)
        titleLabel.textColor = .white

        let back = UIButton(type: .system)
        back.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        back.tintColor = .white
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        view.addSubview(back)
        view.addSubview(titleLabel)

        back.snp.makeConstraints {
            $0.left.equalToSuperview().inset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(4)
            $0.width.height.equalTo(30)
        }

        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(back)
            $0.centerX.equalToSuperview()
        }
    }

    private func setupSearchField() {
        urlTextField.placeholder = "Google.com"
        urlTextField.backgroundColor = UIColor(hex: "#1A1F3C")
        urlTextField.textColor = .white
        urlTextField.font = .systemFont(ofSize: 15)
        urlTextField.layer.cornerRadius = 12
        urlTextField.leftView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        urlTextField.leftViewMode = .always
        urlTextField.clearButtonMode = .whileEditing
        urlTextField.returnKeyType = .go
        urlTextField.delegate = self

        view.addSubview(urlTextField)

        urlTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
    }

    private func setupWebView() {
        webView.backgroundColor = .white
        view.addSubview(webView)

        webView.snp.makeConstraints {
            $0.top.equalTo(urlTextField.snp.bottom).offset(8)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().inset(120)
        }
    }

    private func setupBottomBar() {
        let bar = UIView()
        bar.backgroundColor = UIColor(hex: "#10163A")
        bar.layer.cornerRadius = 20
        bar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bar.clipsToBounds = true

        view.addSubview(bar)

        bar.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(100)
        }

        // buttons
        reloadButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        reloadButton.tintColor = .white
        reloadButton.addTarget(self, action: #selector(reloadPage), for: .touchUpInside)

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        forwardButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        forwardButton.tintColor = .white
        forwardButton.addTarget(self, action: #selector(goForward), for: .touchUpInside)

        printButton.setTitle("Print", for: .normal)
        printButton.setTitleColor(.white, for: .normal)
        printButton.titleLabel?.font = .font(weight: .bold, size: 16)
        printButton.backgroundColor = .systemBlue
        printButton.layer.cornerRadius = 12
        printButton.addTarget(self, action: #selector(printCurrentPage), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [reloadButton, backButton, forwardButton, printButton])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .center
        stack.distribution = .equalSpacing

        bar.addSubview(stack)

        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.right.equalToSuperview().inset(20)
        }

        printButton.snp.makeConstraints {
            $0.width.equalTo(80)
            $0.height.equalTo(36)
        }
    }

    // MARK: - Actions

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func reloadPage() {
        webView.reload()
    }

    @objc private func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    @objc private func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }

    @objc private func printCurrentPage() {
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

                RealmManager.shared.saveDocument(doc) {
                    print("Документ успешно добавлен из галереи")
                }

                let url = DocumentFileManager.shared.fileURL(for: filePath)
                let printController = UIPrintInteractionController.shared
                printController.printingItem = url
                printController.present(animated: true)

            } catch {
                print("Ошибка при сохранении PDF: \(error)")
            }
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
