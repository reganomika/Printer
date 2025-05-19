import UIKit
import SnapKit
import CustomNavigationView
import Utilities

class BaseController: UIViewController {
    
    lazy var topView: CustomNavigationView = {
        let view = CustomNavigationView()
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: .init(named: "background"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupView()
        setupConstraints()
    }
    
    func configurNavigation(
        leftView: UIView? = nil,
        centerView: UIView? = nil,
        rightView: UIView? = nil
    ) {
        topView.leftView = leftView
        topView.centerView = centerView
        topView.rightView = rightView
    }
    
    func setupView() {
        view.backgroundColor = .init(hex: "0B0C1E")
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(topView)
    }
    
    func setupConstraints() {
        
        view.insertSubview(imageView, at: 0)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        topView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
    }
}
