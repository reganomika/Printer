import UIKit
import VisionKit

class ImportController: BaseController {
    private let tableView = UITableView()
    private let navigationTitle = UILabel()
    private let viewModel = ImportViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        configureNavigation()
    }

    private func configureViewHierarchy() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(104)
            $0.left.right.bottom.equalToSuperview()
        }

        tableView.register(ImportInfoCell.self, forCellReuseIdentifier: ImportInfoCell.reuseID)
        tableView.register(BaseCell.self, forCellReuseIdentifier: BaseCell.reuseID)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 100
        tableView.showsVerticalScrollIndicator = false
    }

    private func configureNavigation() {
        let string = "Welcome to\n\(Config.appName)"
        navigationTitle.text = string.localized
        navigationTitle.font = .font(weight: .bold, size: 25)
        navigationTitle.numberOfLines = 0

        let attrString = navigationTitle.getHighlightedText(Config.appName, with: .font(weight: .bold, size: 35))

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        paragraphStyle.maximumLineHeight = 50
        paragraphStyle.alignment = .left
        paragraphStyle.lineHeightMultiple = 1

        attrString?.addAttributes([
            .paragraphStyle: paragraphStyle,
        ], range: .init(location: 0, length: string.count))

        navigationTitle.attributedText = attrString
        view.addSubview(navigationTitle)

        navigationTitle.snp.makeConstraints {
            $0.left.equalToSuperview().inset(25)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(33)
        }
    }
}

extension ImportController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel.cells[indexPath.row]

        if model == .info {
            let cell = tableView.dequeueReusableCell(withIdentifier: ImportInfoCell.reuseID, for: indexPath) as! ImportInfoCell
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: BaseCell.reuseID, for: indexPath) as! BaseCell
        cell.configure(type: model)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = viewModel.cells[indexPath.row]
        return model == .info ? 146.0 : 90.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = viewModel.cells[indexPath.row]
        viewModel.handleSelection(type: type, from: self)
    }
}

extension ImportController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        viewModel.handlePickedImage(image)
    }
}

extension ImportController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }

        do {
            let data = try Data(contentsOf: url)
            let uuid = UUID().uuidString
            let filePath = try DocumentFileManager.shared.savePDF(data: data, withName: uuid)

            let doc = Document(
                id: uuid,
                name: url.deletingPathExtension().lastPathComponent,
                filePath: filePath,
                dateAdded: Date(),
                lastModified: Date(),
                source: .file
            )

            RealmManager.shared.saveDocument(doc) {
                print("📄 Документ из файлов добавлен")
            }

        } catch {
            print("❌ Ошибка при импорте файла: \(error)")
        }
    }
}

extension ImportController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true)

        let pdfData = NSMutableData()
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: UIScreen.main.bounds)

        let data = pdfRenderer.pdfData { context in
            for i in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: i)
                context.beginPage()
                image.draw(in: CGRect(origin: .zero, size: UIScreen.main.bounds.size))
            }
        }

        do {
            let uuid = UUID().uuidString
            let filePath = try DocumentFileManager.shared.savePDF(data: data, withName: uuid)

            let doc = Document(
                id: uuid,
                name: "Scanned Document",
                filePath: filePath,
                dateAdded: Date(),
                lastModified: Date(),
                source: .scan
            )

            RealmManager.shared.saveDocument(doc) {
                print("📄 Скан добавлен")
            }

        } catch {
            print("❌ Ошибка при сохранении скана: \(error)")
        }
    }
}
