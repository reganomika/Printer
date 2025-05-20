import RealmSwift
import Foundation

enum DocumentSource: String {
    case photo
    case scan
    case file
    case browser
}

struct Document {
    let id: String
    var name: String
    var filePath: String
    var dateAdded: Date
    var lastModified: Date
    var source: DocumentSource
}

class DocumentRLM: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var filePath: String = ""
    @objc dynamic var dateAdded: Date = Date()
    @objc dynamic var lastModified: Date = Date()
    @objc dynamic var sourceRaw: String = DocumentSource.photo.rawValue

    var source: DocumentSource {
        get { DocumentSource(rawValue: sourceRaw) ?? .photo }
        set { sourceRaw = newValue.rawValue }
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(from document: Document) {
        self.init()
        self.id = document.id
        self.name = document.name
        self.filePath = document.filePath
        self.dateAdded = document.dateAdded
        self.lastModified = document.lastModified
        self.source = document.source
    }

    func toDocument() -> Document {
        return Document(
            id: id,
            name: name,
            filePath: filePath,
            dateAdded: dateAdded,
            lastModified: lastModified,
            source: source
        )
    }
}

final class RealmManager {
    static let shared = RealmManager()
    private let realm = try! Realm()
    
    private func performRealmWrite(_ completion: @escaping (Realm) -> Void) {
        DispatchQueue.main.async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    try realm.write {
                        completion(realm)
                    }
                } catch {
                    print("Ошибка при записи в Realm: \(error)")
                }
            }
        }
    }

    func saveDocument(_ document: Document, _ completion: @escaping () -> Void) {
        performRealmWrite { realm in
            let documentRLM = DocumentRLM(from: document)
            realm.add(documentRLM, update: .modified)
            completion()
        }
    }
    
    func getAllDocuments() -> [Document] {
        let results = realm.objects(DocumentRLM.self)
        return results.map { $0.toDocument() }.sorted(by: { $0.lastModified > $1.lastModified })
    }

    func deleteDocument(_ document: Document, _ completion: @escaping () -> Void) {
        performRealmWrite { realm in
            if let documentRLM = realm.object(ofType: DocumentRLM.self, forPrimaryKey: document.id) {
                DocumentFileManager.shared.deleteFile(at: document.filePath)
                realm.delete(documentRLM)
                completion()
            }
        }
    }

    func updateDocument(_ document: Document, _ completion: @escaping () -> Void) {
        performRealmWrite { realm in
            if let documentRLM = realm.object(ofType: DocumentRLM.self, forPrimaryKey: document.id) {
                documentRLM.name = document.name
                documentRLM.lastModified = Date()
                completion()
            }
        }
    }
}
