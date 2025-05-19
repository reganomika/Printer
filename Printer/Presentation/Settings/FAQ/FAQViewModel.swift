struct FAQModel {
    let title: String
    let subtitle: String
}

final class FAQViewModel {
    
    let models: [FAQModel] = [
        .init(
            title: "How to connect to Printer".localized,
            subtitle: "faq0".localized
        ),
        .init(
            title: "Is the app compatible with my printer model?".localized,
            subtitle: "faq1".localized
        ),
        .init(
            title: "Why can’t the app find my printer?".localized,
            subtitle: "faq2".localized
        ),
        .init(
            title: "What document formats can I print?".localized,
            subtitle: "faq3".localized
        )
    ]
}
