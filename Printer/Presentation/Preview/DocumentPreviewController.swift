import UIKit
import PDFKit
import VisionKit
import UniformTypeIdentifiers
import QuickLook

final class DocumentPreviewController: UIViewController {

    private let document: Document
    
    private var editableCopyURL: URL?
    
    private lazy var previewItem: URL = {
        DocumentFileManager.shared.fileURL(for: document.filePath)
    }()

    // MARK: - UI

    private let pdfView = PDFView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let printButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)
    
    private let actionStack = UIStackView()
    private let editButton = UIButton(type: .system)
    private let addPagesButton = UIButton(type: .system)

    // MARK: - Init

    init(document: Document) {
        self.document = document
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

        // PDF View
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        view.addSubview(pdfView)
        pdfView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(160)
            $0.left.right.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(120)
        }

        // Title
        titleLabel.text = document.name
        titleLabel.textColor = .white
        titleLabel.font = .font(weight: .bold, size: 20)
        titleLabel.lineBreakMode = .byTruncatingTail
        view.addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.left.equalToSuperview().inset(60)
            $0.right.lessThanOrEqualToSuperview().inset(100)
        }

        // Date
        dateLabel.text = DateFormatter.displayDate.string(from: document.dateAdded)
        dateLabel.textColor = UIColor(hex: "ADACB8")
        dateLabel.font = .font(weight: .medium, size: 14)
        view.addSubview(dateLabel)

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.left.equalTo(titleLabel)
        }

        // Back Button
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        view.addSubview(backButton)

        backButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(16)
            $0.centerY.equalTo(titleLabel)
            $0.size.equalTo(30)
        }

        // Print Button
        printButton.setTitle("Print", for: .normal)
        printButton.setTitleColor(.white, for: .normal)
        printButton.titleLabel?.font = .font(weight: .bold, size: 16)
        printButton.backgroundColor = UIColor.systemBlue
        printButton.layer.cornerRadius = 12
        printButton.addTarget(self, action: #selector(didTapPrint), for: .touchUpInside)
        view.addSubview(printButton)

        printButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.right.equalToSuperview().inset(16)
            $0.height.equalTo(36)
            $0.width.equalTo(80)
        }

        // Action Buttons (Edit + Add Pages)
        actionStack.axis = .horizontal
        actionStack.spacing = 16
        actionStack.distribution = .fillEqually

        configureActionButton(editButton, title: "Edit", icon: "pencil")
        configureActionButton(addPagesButton, title: "Add pages", icon: "plus.square.on.square")

        editButton.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
        addPagesButton.addTarget(self, action: #selector(didTapAddPages), for: .touchUpInside)

        actionStack.addArrangedSubview(editButton)
        actionStack.addArrangedSubview(addPagesButton)
        view.addSubview(actionStack)

        actionStack.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(32)
            $0.height.equalTo(56)
        }
    }

    private func configureActionButton(_ button: UIButton, title: String, icon: String) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: icon)
        config.imagePadding = 8
        config.baseBackgroundColor = UIColor(hex: "#10163A")
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        button.configuration = config
    }

    private func loadPDF() {
        let url = DocumentFileManager.shared.fileURL(for: document.filePath)
        if let doc = PDFDocument(url: url) {
            pdfView.document = doc
        }
    }

    // MARK: - Actions

    @objc private func didTapBack() {
        dismiss()
    }

    @objc private func didTapPrint() {
        let url = DocumentFileManager.shared.fileURL(for: document.filePath)
        let controller = UIPrintInteractionController.shared
        controller.printingItem = url
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
    
    private func presentScanner() {
        guard VNDocumentCameraViewController.isSupported else {
            print("Сканер не поддерживается")
            return
        }

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
        let types = [UTType.pdf]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    private func appendPDF(data: Data) {
        let currentURL = DocumentFileManager.shared.fileURL(for: document.filePath)
        guard
            let currentDoc = PDFDocument(url: currentURL),
            let newDoc = PDFDocument(data: data)
        else { return }

        let combinedDoc = PDFDocument()

        // Добавляем страницы текущего документа
        for i in 0..<currentDoc.pageCount {
            if let page = currentDoc.page(at: i) {
                combinedDoc.insert(page, at: combinedDoc.pageCount)
            }
        }

        // Добавляем страницы нового документа
        for i in 0..<newDoc.pageCount {
            if let page = newDoc.page(at: i) {
                combinedDoc.insert(page, at: combinedDoc.pageCount)
            }
        }

        // Сохраняем новый файл, перезаписывая старый
        if let combinedData = combinedDoc.dataRepresentation() {
            do {
                try DocumentFileManager.shared.replaceFile(at: document.filePath, with: combinedData)
                RealmManager.shared.updateDocument(document) {
                    print("📄 Документ обновлён")
                }
                loadPDF() // Перезагружаем PDF
            } catch {
                print("❌ Не удалось сохранить объединённый PDF: \(error)")
            }
        }
    }
}

extension DocumentPreviewController: AddPagesSourceSelectorDelegate {
    func addPagesSourceSelectorDidSelect(_ source: AddPageSource) {
        switch source {
        case .camera:
            presentScanner()
        case .gallery:
            presentImagePicker()
        case .files:
            presentDocumentPicker()
        }
    }
}

extension DocumentPreviewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true)

        let pdfData = UIGraphicsPDFRenderer(bounds: UIScreen.main.bounds).pdfData { ctx in
            for i in 0..<scan.pageCount {
                let img = scan.imageOfPage(at: i)
                ctx.beginPage()
                img.draw(in: CGRect(origin: .zero, size: UIScreen.main.bounds.size))
            }
        }

        appendPDF(data: pdfData)
    }
}

extension DocumentPreviewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }

        let pdfData = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: image.size)).pdfData { ctx in
            ctx.beginPage()
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
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let originalURL = DocumentFileManager.shared.fileURL(for: document.filePath)
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent("edit_session_\(UUID().uuidString).pdf")

        do {
            try FileManager.default.copyItem(at: originalURL, to: tempURL)
            editableCopyURL = tempURL
            return tempURL as QLPreviewItem
        } catch {
            print("Ошибка копирования PDF для редактирования: \(error)")
            return originalURL as QLPreviewItem
        }
    }
}

extension DocumentPreviewController: QLPreviewControllerDelegate {
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        return .updateContents
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        if let url = controller.currentPreviewItem?.previewItemURL {
            do {
                let targetPath = document.filePath
                try DocumentFileManager.shared.replaceFile(at: targetPath, with: try Data(contentsOf: url))

                RealmManager.shared.updateDocument(document) {
                    print("✅ Документ обновлён после редактирования")
                }

                loadPDF()
            } catch {
                print("❌ Не удалось сохранить изменённую копию: \(error)")
            }
        }
    }
}
