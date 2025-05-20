import UIKit
import UniformTypeIdentifiers
import VisionKit

enum ImportCellType: CaseIterable {
    case info
    case gallery
    case scan
    case files
    case browser

    var iconAsset: UIImage? {
        switch self {
        case .gallery: return UIImage(named: "gallery")
        case .scan: return UIImage(named: "scan")
        case .browser: return UIImage(named: "browser")
        case .files: return UIImage(named: "files")
        default: return nil
        }
    }

    var displayTitle: String? {
        switch self {
        case .gallery: return "Gallery".localized
        case .scan: return "Scan".localized
        case .browser: return "Browser".localized
        case .files: return "Files".localized
        default: return nil
        }
    }
}

final class ImportViewModel {
    let cells = ImportCellType.allCases
    
    func handleSelection(type: ImportCellType, from controller: UIViewController) {
        switch type {
        case .gallery:
            presentImagePicker(from: controller)
        case .browser:
            presentBrowser(from: controller)
        case .files:
            presentDocumentPicker(from: controller)
        case .scan:
            presentScanner(from: controller)
        default:
            break
        }
    }
    
    private func presentScanner(from controller: UIViewController) {
        guard VNDocumentCameraViewController.isSupported else {
            print("Сканер не поддерживается")
            return
        }

        let scanner = VNDocumentCameraViewController()
        scanner.delegate = controller as? VNDocumentCameraViewControllerDelegate
        controller.present(scanner, animated: true)
    }
    
    private func presentDocumentPicker(from controller: UIViewController) {
        let types = [UTType.pdf]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.allowsMultipleSelection = false
        picker.delegate = controller as? UIDocumentPickerDelegate
        controller.present(picker, animated: true)
    }
    
    private func presentBrowser(from controller: UIViewController) {
        controller.present(vc: BrowserPrintController())
    }

    private func presentImagePicker(from controller: UIViewController) {
        let picker = UIImagePickerController()
        picker.delegate = controller as? any (UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        picker.sourceType = .photoLibrary
        controller.present(picker, animated: true)
    }

    func handlePickedImage(_ image: UIImage) {
        let pdfData = createPDF(from: image)

        do {
            let uuid = UUID().uuidString
            let filePath = try DocumentFileManager.shared.savePDF(data: pdfData, withName: uuid)

            let doc = Document(
                id: uuid,
                name: "From Gallery",
                filePath: filePath,
                dateAdded: Date(),
                lastModified: Date(),
                source: .photo
            )

            RealmManager.shared.saveDocument(doc) {
                print("Документ успешно добавлен из галереи")
            }
        } catch {
            print("Ошибка при сохранении PDF: \(error)")
        }
    }

    private func createPDF(from image: UIImage) -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: image.size))
        return pdfRenderer.pdfData { context in
            context.beginPage()
            image.draw(at: .zero)
        }
    }
}
