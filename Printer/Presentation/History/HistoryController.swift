import UIKit
import PremiumManager
import RealmSwift
import ShadowImageButton

final class HistoryController: BaseController {

    private let viewModel = HistoryViewModel()
    private let tableView = UITableView()
    private let navigationTitle = UILabel()

    private let emptyStateView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureTableView()
        configureEmptyState()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startObserving()
    }

    private func configureNavigation() {
        navigationTitle.text = "History".localized
        navigationTitle.font = .font(weight: .bold, size: 28)
        configurNavigation(leftView: navigationTitle)
    }

    private func configureTableView() {
        tableView.register(BaseCell.self, forCellReuseIdentifier: BaseCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.isHidden = true
        tableView.contentInset.top = 20
        tableView.contentInset.bottom = 100
        view.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
    }

    private func configureEmptyState() {
        let imageView = UIImageView(image: UIImage(named: "emptyHistory"))
        imageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.font = .font(weight: .bold, size: 22)
        titleLabel.text = "It looks empty here".localized
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.font = .font(weight: .medium, size: 16)
        subtitleLabel.textColor = UIColor(hex: "ADACB8")
        subtitleLabel.text = "Add your first document to begin".localized
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 9

        let button = ShadowImageButton()
        button.configure(
            buttonConfig: .init(
                title: "Add document".localized,
                font: .font(weight: .bold, size: 18),
                textColor: .white,
                image: nil
            ),
            backgroundImageConfig: .init(
                image: UIImage(named: "settingsPremiumBackground"),
                cornerRadius: 18,
                shadowConfig: .init(
                    color: UIColor(hex: "0044FF"),
                    opacity: 0.5,
                    offset: CGSize(width: 0, height: 4),
                    radius: 14.7
                )
            )
        )
        button.action = { [weak self] in self?.openImport() }

        emptyStateView.addSubview(imageView)
        emptyStateView.addSubview(stack)
        emptyStateView.addSubview(button)
        view.addSubview(emptyStateView)

        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-100)
            $0.horizontalEdges.equalToSuperview()
        }

        stack.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(21)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(50)
        }

        button.snp.makeConstraints {
            $0.top.equalTo(stack.snp.bottom).offset(28)
            $0.height.equalTo(69)
            $0.horizontalEdges.equalToSuperview().inset(84)
        }

        emptyStateView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            let isEmpty = self.viewModel.documents.isEmpty
            self.tableView.isHidden = isEmpty
            self.emptyStateView.isHidden = !isEmpty
            self.tableView.reloadData()
        }
    }

    @objc private func openImport() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if let tabbar = parent?.parent as? TabBarController {
            tabbar.switchToViewController(0)
        }
    }
    
    private func viewDocument(_ document: Document) {
        let previewVC = DocumentPreviewController(document: document)
        present(vc: previewVC)
    }
    
    private func shareDocument(_ document: Document) {
        let fileURL = DocumentFileManager.shared.fileURL(for: document.filePath)

        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY - 40, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        present(activityVC, animated: true)
    }
    
    private func printDocument(_ document: Document) {
        
        guard PremiumManager.shared.isPremium.value else {
            PaywallManager.shared.showPaywall()
            return
        }
        
        if Storage.shared.buttonsTapNumber > 4, !Storage.shared.wasReviewScreen {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIApplication.topViewController()?.presentCrossDissolve(vc: ReviewController())
            }
        }
        Storage.shared.buttonsTapNumber += 1
        
        let fileURL = DocumentFileManager.shared.fileURL(for: document.filePath)

        let printController = UIPrintInteractionController.shared
        printController.printingItem = fileURL

        printController.present(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension HistoryController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.documents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let doc = viewModel.documents[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: BaseCell.reuseID, for: indexPath) as! BaseCell
        cell.configureForDocument(document: doc)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HistoryController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let document = viewModel.documents[indexPath.row]
        viewDocument(document)
    }
}

extension HistoryController: BaseCellDelegate {
    func baseCellDidTapMenu(_ cell: BaseCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let document = viewModel.documents[indexPath.row]
        showActions(for: document)
    }

    private func showActions(for document: Document) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "View".localized, style: .default) { _ in
            self.viewDocument(document)
        })

        alert.addAction(UIAlertAction(title: "Share".localized, style: .default) { _ in
            self.shareDocument(document)
        })

        alert.addAction(UIAlertAction(title: "Print".localized, style: .default) { _ in
            self.printDocument(document)
        })

        alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive) { _ in
            RealmManager.shared.deleteDocument(document) {
                print("Документ удалён")
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        present(alert, animated: true)
    }
}
