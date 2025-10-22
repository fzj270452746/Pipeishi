
import UIKit

final class SettingsNavigationControl: UIControl {

    private lazy var primaryTitleLabel = UILabel()
    private lazy var secondaryDescriptionLabel = UILabel()
    private lazy var chevronIcon = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        assembleControlLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        assembleControlLayout()
    }

    private func assembleControlLayout() {
        layer.cornerRadius = 14
        layer.masksToBounds = false
        backgroundColor = UIColor(red: 0.19, green: 0.26, blue: 0.30, alpha: 0.85)
        layer.borderWidth = 1.0
        layer.borderColor = UIColor(red: 0.42, green: 0.54, blue: 0.63, alpha: 0.8).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)

        primaryTitleLabel.text = "Settings & Lore"
        primaryTitleLabel.textColor = UIColor(red: 0.93, green: 0.87, blue: 0.70, alpha: 1.0)
        primaryTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)

        secondaryDescriptionLabel.text = "Gameplay guide, feedback, privacy"
        secondaryDescriptionLabel.textColor = UIColor(red: 0.74, green: 0.81, blue: 0.83, alpha: 1.0)
        secondaryDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)

        chevronIcon.tintColor = UIColor(red: 0.78, green: 0.63, blue: 0.43, alpha: 1.0)
        chevronIcon.contentMode = .scaleAspectFit
        chevronIcon.setContentHuggingPriority(.required, for: .horizontal)
        chevronIcon.isUserInteractionEnabled = false

        let textLabelStack = UIStackView(arrangedSubviews: [primaryTitleLabel, secondaryDescriptionLabel])
        textLabelStack.axis = .vertical
        textLabelStack.spacing = 4
        textLabelStack.isUserInteractionEnabled = false

        let horizontalLayout = UIStackView(arrangedSubviews: [textLabelStack, chevronIcon])
        horizontalLayout.axis = .horizontal
        horizontalLayout.alignment = .center
        horizontalLayout.spacing = 12
        horizontalLayout.translatesAutoresizingMaskIntoConstraints = false
        horizontalLayout.isUserInteractionEnabled = false

        addSubview(horizontalLayout)
        NSLayoutConstraint.activate([
            horizontalLayout.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            horizontalLayout.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            horizontalLayout.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            horizontalLayout.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
