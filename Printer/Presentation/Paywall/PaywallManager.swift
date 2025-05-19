import UIKit
import PremiumManager

final class PaywallManager {
    static let shared = PaywallManager()
    
    func getPaywall(isFromOnboarding: Bool = false) -> UIViewController {
        
        switch PremiumManager.shared.paywallType.value {
        case .second:
            let vc = PaywallFirstVariantController(isFromOnboarding: isFromOnboarding)
            vc.modalPresentationStyle = .fullScreen
            return vc
        case .first:
            let vc = PaywallSecondVariantController(isFromOnboarding: isFromOnboarding)
            vc.modalPresentationStyle = .fullScreen
            return vc
        }
    }
    
    func showPaywall() {
        UIApplication.topViewController()?.present(vc: getPaywall(isFromOnboarding: false))
    }
}
