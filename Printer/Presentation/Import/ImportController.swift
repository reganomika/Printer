import UIKit

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
        
        tableView.register(
            ImportInfoCell.self,
            forCellReuseIdentifier: ImportInfoCell.reuseID
        )
        
        tableView.register(
            BaseCell.self,
            forCellReuseIdentifier: BaseCell.reuseID
        )
        
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
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
        ]
                
        attrString?.addAttributes(attributes, range: .init(location: 0, length: string.count))
        
        navigationTitle.attributedText = attrString
        view.addSubview(navigationTitle)
        
        navigationTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(25)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(33)
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
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ImportInfoCell.reuseID,
                for: indexPath
            ) as! ImportInfoCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BaseCell.reuseID,
            for: indexPath
        ) as! BaseCell
        cell.configure(type: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = viewModel.cells[indexPath.row]
        
        if model == .info {
            return 146.0
        }
        return 90.0
    }
}

extension UILabel {
    func getHighlightedText(_ text: String, with font: UIFont) -> NSMutableAttributedString? {
        guard let labelText = self.text else { return nil }
        
        let attributedString = NSMutableAttributedString(string: labelText)
        let range = (labelText as NSString).range(of: text)
        attributedString.addAttribute(.font, value: font, range: range)
        
        return attributedString
    }
}
