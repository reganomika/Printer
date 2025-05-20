import UIKit
import PremiumManager
import PDFKit
import VisionKit
import UniformTypeIdentifiers
import QuickLook
import ShadowImageButton

final class DocumentPreviewController: UIViewController {

    private let viewModel: DocumentPreviewViewModel
    private var editableCopyURL: URL?

    // MARK: - UI

    private let pdfView = PDFView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private let actionStack = UIStackView()
    private let editButton = UIButton(type: .system)
    private let addPagesButton = UIButton(type: .system)
    
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
        $0.action = { [weak self] in self?.didTapPrint() }
    }
    
    private lazy var shadowImageView: UIImageView = {
        let view = UIImageView(image: .init(named: "shadow"))
        view.contentMode = .scaleAspectFill
        return view
    }()

    // MARK: - Init

    init(document: Document) {
        self.viewModel = DocumentPreviewViewModel(document: document)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPDF()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#0A0F2E")

        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .clear
        view.addSubview(pdfView)
        pdfView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(160)
            $0.left.right.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }

        titleLabel.text = viewModel.document.name
        titleLabel.textColor = .white
        titleLabel.font = .font(weight: .bold, size: 18)
        titleLabel.lineBreakMode = .byTruncatingTail
        view.addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(19)
            $0.left.equalToSuperview().inset(63)
            $0.right.lessThanOrEqualToSuperview().inset(100)
        }

        dateLabel.text = DateFormatter.displayDate.string(from: viewModel.document.dateAdded)
        dateLabel.textColor = UIColor(hex: "ADACB8")
        dateLabel.font = .font(weight: .medium, size: 16)
        view.addSubview(dateLabel)

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.left.equalTo(titleLabel)
        }

        backButton.setImage(UIImage(named: "left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        view.addSubview(backButton)

        backButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(25)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(19)
            $0.size.equalTo(24)
        }
        
        view.addSubview(printButton)

        printButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(26)
            $0.right.equalToSuperview().inset(25)
            $0.height.equalTo(35)
            $0.width.equalTo(90)
        }
        
        view.addSubview(shadowImageView)
        shadowImageView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(182)
        }

        actionStack.axis = .horizontal
        actionStack.spacing = 16
        actionStack.distribution = .fillEqually

        configureActionButton(editButton, title: "Edit".localized, icon: "edit")
        configureActionButton(addPagesButton, title: "Add pages".localized, icon: "addPages")

        editButton.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
        addPagesButton.addTarget(self, action: #selector(didTapAddPages), for: .touchUpInside)

        actionStack.addArrangedSubview(editButton)
        actionStack.addArrangedSubview(addPagesButton)
        view.addSubview(actionStack)

        actionStack.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(26)
            $0.bottom.equalToSuperview().inset(32)
            $0.height.equalTo(64)
        }
    }

    private func configureActionButton(_ button: UIButton, title: String, icon: String) {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: icon)
        config.imagePadding = 10
        config.baseBackgroundColor = UIColor(hex: "#101B37")
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule

        let font = UIFont.font(weight: .bold, size: 16)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        config.attributedTitle = AttributedString(attributedTitle)

        button.configuration = config
    }

    private func loadPDF() {
        if let doc = viewModel.loadPDF() {
            pdfView.document = doc
        }
    }

    // MARK: - Actions

    @objc private func didTapBack() {
        dismiss()
    }

    @objc private func didTapPrint() {
        
        guard PremiumManager.shared.isPremium.value else {
            PaywallManager.shared.showPaywall()
            return
        }
        
        if Storage.shared.buttonsTapNumber > 4, !Storage.shared.wasReviewScreen {
            Storage.shared.wasReviewScreen = true
            UIApplication.topViewController()?.presentCrossDissolve(vc: ReviewController())
        }
        Storage.shared.buttonsTapNumber += 1
        
        let controller = UIPrintInteractionController.shared
        controller.printingItem = viewModel.documentURL
        controller.present(animated: true)
    }

    @objc private func didTapEdit() {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        present(previewController, animated: true)
    }

    @objc private func didTapAddPages() {
        let selector = AddPagesSourceSelectorController()
        selector.delegate = self
        presentCrossDissolve(vc: selector)
    }

    private func appendPDF(data: Data) {
        if viewModel.appendPDF(with: data) {
            loadPDF()
        }
    }

    private func presentScanner() {
        guard VNDocumentCameraViewController.isSupported else { return }
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = self
        present(scanner, animated: true)
    }

    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    private func presentDocumentPicker() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension DocumentPreviewController: AddPagesSourceSelectorDelegate {
    func addPagesSourceSelectorDidSelect(_ source: AddPageSource) {
        switch source {
        case .camera: presentScanner()
        case .gallery: presentImagePicker()
        case .files: presentDocumentPicker()
        }
    }
}

extension DocumentPreviewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true)
        let data = UIGraphicsPDFRenderer(bounds: UIScreen.main.bounds).pdfData { ctx in
            for i in 0..<scan.pageCount {
                let img = scan.imageOfPage(at: i)
                ctx.beginPage()
                img.draw(in: CGRect(origin: .zero, size: UIScreen.main.bounds.size))
            }
        }
        appendPDF(data: data)
    }
}

extension DocumentPreviewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        let pdfData = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: image.size)).pdfData {
            $0.beginPage()
            image.draw(at: .zero)
        }
        appendPDF(data: pdfData)
    }
}

extension DocumentPreviewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first, let data = try? Data(contentsOf: url) else { return }
        appendPDF(data: data)
    }
}

extension DocumentPreviewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        if let copy = viewModel.editableCopyURL() {
            editableCopyURL = copy
            return copy as QLPreviewItem
        }
        return viewModel.documentURL as QLPreviewItem
    }
}

extension DocumentPreviewController: QLPreviewControllerDelegate {
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        .updateContents
    }

    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        guard let url = controller.currentPreviewItem?.previewItemURL,
              let data = try? Data(contentsOf: url)
        else { return }

        viewModel.replaceDocument(with: data)
        loadPDF()
    }
}
