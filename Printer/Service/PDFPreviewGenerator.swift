import UIKit

class PDFPreviewGenerator {
    static let shared = PDFPreviewGenerator()

    func previewImage(for path: String) -> UIImage? {
        guard let pdf = CGPDFDocument(URL(fileURLWithPath: path) as CFURL),
              let page = pdf.page(at: 1) else { return nil }

        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            ctx.cgContext.drawPDFPage(page)
        }
        return img
    }
}
