import UIKit
import Utilities

class GradientLabel: UIStackView {
    
    private var startPoint: CGPoint
    private var endPoint: CGPoint
    private var gradientColors: [UIColor]?
    private var plainColor: UIColor?
    
    private let defaultGradinetColors = [UIColor(hex: "#18FBFF"), UIColor(hex: "#006FFF")]
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    
    init(
        startPoint: CGPoint = CGPoint(x: 0.0, y: 0.5),
        endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5)
    ) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        super.init(frame: .zero)
        setupView()
        self.gradientColors = defaultGradinetColors
    }

    required init(coder: NSCoder) {
        self.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.endPoint = CGPoint(x: 1.0, y: 0.5)
        super.init(coder: coder)
        setupView()
        self.gradientColors = defaultGradinetColors
    }

    private func setupView() {
        axis = .vertical
        alignment = .center
        addArrangedSubview(label)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradientOrColor()
    }

    func setLabelColor(colors: [UIColor]? = [UIColor(hex: "#18FBFF"), UIColor(hex: "#006FFF")], plainColor: UIColor? = nil) {
        if let plainColor = plainColor {
            self.plainColor = plainColor
            self.gradientColors = nil
        } else if let colors = colors {
            self.gradientColors = colors
            self.plainColor = nil
        }
        applyGradientOrColor()
    }

    private func applyGradientOrColor() {
        if let plainColor = plainColor {
            label.textColor = plainColor
        } else if let colors = gradientColors {
            let gradientImage = UIImage.gradientImage(
                bounds: label.bounds,
                colors: colors,
                startPoint: startPoint,
                endPoint: endPoint
            )
            label.textColor = UIColor(patternImage: gradientImage)
        }
    }
}
