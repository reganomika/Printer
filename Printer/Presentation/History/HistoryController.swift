import UIKit

class HistoryController: BaseController {
    private let tableView = UITableView()
    private let navigationTitle = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        configureNavigation()
    }
    
    private func configureViewHierarchy() {
        //        view.addSubview(tableView)
        //        tableView.snp.makeConstraints {
        //            $0.top.equalTo(topView.snp.bottom)
        //            $0.left.right.bottom.equalToSuperview()
        //        }
        //
        //        tableView.register(
        //            PremiumCell.self,
        //            forCellReuseIdentifier: PremiumCell.reuseID
        //        )
        //        tableView.register(
        //            BaseCell.self,
        //            forCellReuseIdentifier: BaseCell.reuseID
        //        )
        //
        //        tableView.delegate = self
        //        tableView.dataSource = self
        //        tableView.backgroundColor = .clear
        //        tableView.separatorStyle = .none
        //        tableView.contentInset.top = 10
        //        tableView.contentInset.bottom = 100
        //        tableView.showsVerticalScrollIndicator = false
    }
    
    private func configureNavigation() {
        navigationTitle.text = "History".localized
        navigationTitle.font = .font(weight: .bold, size: 25)
        configurNavigation(leftView: navigationTitle)
    }
}
