import UIKit

struct Font {
    enum Weight: String {
        case medium = "Sailec-Medium"
        case bold = "Sailec-Bold"
        case light = "Sailec-Light"
    }

    static func font(weight: Weight, size: CGFloat) -> UIFont {
        return UIFont(name: weight.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}

extension UIFont {
    static func font(weight: Font.Weight, size: CGFloat) -> UIFont {
        return Font.font(weight: weight, size: size)
    }
}
