import Foundation

final class DocumentFileManager {
    static let shared = DocumentFileManager()
    
    private init() {}

    private var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("DocumentsStorage", isDirectory: true)
    }

    private func ensureDirectoryExists() {
        let path = documentsDirectory
        if !FileManager.default.fileExists(atPath: path.path) {
            try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
        }
    }

    func generateFilePath(for name: String) -> String {
        ensureDirectoryExists()
        let filename = "\(UUID().uuidString)_\(name).pdf"
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        return fileURL.path
    }

    func savePDF(data: Data, withName name: String) throws -> String {
        let filePath = generateFilePath(for: name)
        let url = URL(fileURLWithPath: filePath)
        try data.write(to: url)
        return filePath
    }

    func fileURL(for path: String) -> URL {
        return URL(fileURLWithPath: path)
    }

    func deleteFile(at path: String) {
        let url = URL(fileURLWithPath: path)
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }

    func replaceFile(at path: String, with newData: Data) throws {
        let url = URL(fileURLWithPath: path)
        try newData.write(to: url, options: .atomic)
    }

    func fileExists(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
}
