import UIKit

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

class ImportViewModel {
    let cells = ImportCellType.allCases
}
