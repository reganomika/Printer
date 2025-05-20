import RealmSwift

final class HistoryViewModel {

    var onUpdate: (() -> Void)?
    private var notificationToken: NotificationToken?
    private(set) var documents: [Document] = []

    func startObserving() {
        let realm = try? Realm()
        let results = realm?.objects(DocumentRLM.self)
        
        guard let results else { return }

        notificationToken = results.observe { [weak self] changes in
            guard let self else { return }
            
            self.documents = results.map { $0.toDocument() }
            self.onUpdate?()
        }
    }

    func stopObserving() {
        notificationToken?.invalidate()
        notificationToken = nil
    }
}
