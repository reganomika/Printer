import Foundation
import PDFKit

final class DocumentPreviewViewModel {

    private(set) var document: Document

    init(document: Document) {
        self.document = document
    }

    var documentURL: URL {
        DocumentFileManager.shared.fileURL(for: document.filePath)
    }

    func loadPDF() -> PDFDocument? {
        PDFDocument(url: documentURL)
    }

    func editableCopyURL() -> URL? {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("edit_session_\(UUID().uuidString).pdf")
        do {
            try FileManager.default.copyItem(at: documentURL, to: tempURL)
            return tempURL
        } catch {
            return nil
        }
    }

    func replaceDocument(with data: Data) {
        do {
            try DocumentFileManager.shared.replaceFile(at: document.filePath, with: data)
            RealmManager.shared.updateDocument(document) {}
        } catch {}
    }

    func appendPDF(with newData: Data) -> Bool {
        guard let currentDoc = PDFDocument(url: documentURL),
              let newDoc = PDFDocument(data: newData)
        else { return false }

        let resultDoc = PDFDocument()

        for i in 0..<currentDoc.pageCount {
            if let page = currentDoc.page(at: i) {
                resultDoc.insert(page, at: resultDoc.pageCount)
            }
        }

        for i in 0..<newDoc.pageCount {
            if let page = newDoc.page(at: i) {
                resultDoc.insert(page, at: resultDoc.pageCount)
            }
        }

        guard let finalData = resultDoc.dataRepresentation() else { return false }

        replaceDocument(with: finalData)
        return true
    }
}
