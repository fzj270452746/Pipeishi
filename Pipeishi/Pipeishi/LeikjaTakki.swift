

import UIKit

final class ChallengeLevelButton: UIControl {

    private let challengeType: ChallengeLevel
    private lazy var backgroundGradientLayer = CAGradientLayer()
    private lazy var shadowRenderLayer = CALayer()
    private lazy var primaryTitleLabel = UILabel()
    private lazy var secondaryDescriptionLabel = UILabel()
    private lazy var verticalLabelStack = UIStackView()

    init(challengeType: ChallengeLevel) {
        self.challengeType = challengeType
        super.init(frame: .zero)
        assembleButton()
    }

    required init?(coder: NSCoder) {
        self.challengeType = .relaxed
        super.init(coder: coder)
        assembleButton()
    }

    override var isHighlighted: Bool {
        didSet {
            let scaleFactor: CGFloat = isHighlighted ? 0.96 : 1.0
            UIView.animate(withDuration: 0.18) {
                self.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
                self.alpha = self.isHighlighted ? 0.85 : 1.0
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundGradientLayer.frame = bounds
        shadowRenderLayer.frame = bounds
        let cornerRadius = bounds.height / 2
        backgroundGradientLayer.cornerRadius = cornerRadius
        shadowRenderLayer.cornerRadius = cornerRadius
    }

    private func assembleButton() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(greaterThanOrEqualToConstant: 72).isActive = true

        layer.insertSublayer(shadowRenderLayer, at: 0)
        layer.insertSublayer(backgroundGradientLayer, above: shadowRenderLayer)
        shadowRenderLayer.backgroundColor = UIColor.black.withAlphaComponent(0.35).cgColor
        shadowRenderLayer.shadowColor = UIColor.black.cgColor
        shadowRenderLayer.shadowOpacity = 0.4
        shadowRenderLayer.shadowRadius = 12
        shadowRenderLayer.shadowOffset = CGSize(width: 0, height: 8)

        backgroundGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        backgroundGradientLayer.colors = generateGradientColors(forChallenge: challengeType)

        primaryTitleLabel.text = challengeType.displayName
        primaryTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        primaryTitleLabel.textColor = .white
        primaryTitleLabel.textAlignment = .center
        primaryTitleLabel.isUserInteractionEnabled = false

        secondaryDescriptionLabel.text = generateDescriptionText(forChallenge: challengeType)
        secondaryDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        secondaryDescriptionLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        secondaryDescriptionLabel.textAlignment = .center
        secondaryDescriptionLabel.isUserInteractionEnabled = false

        verticalLabelStack.axis = .vertical
        verticalLabelStack.alignment = .center
        verticalLabelStack.spacing = 8
        verticalLabelStack.translatesAutoresizingMaskIntoConstraints = false
        verticalLabelStack.isUserInteractionEnabled = false
        verticalLabelStack.addArrangedSubview(primaryTitleLabel)
        verticalLabelStack.addArrangedSubview(secondaryDescriptionLabel)

        addSubview(verticalLabelStack)
        NSLayoutConstraint.activate([
            verticalLabelStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            verticalLabelStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            verticalLabelStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            verticalLabelStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    private func generateGradientColors(forChallenge challenge: ChallengeLevel) -> [CGColor] {
        if challenge == .relaxed {
            return [
                UIColor(red: 0.43, green: 0.74, blue: 0.58, alpha: 1.0).cgColor,
                UIColor(red: 0.27, green: 0.61, blue: 0.47, alpha: 1.0).cgColor
            ]
        } else {
            return [
                UIColor(red: 0.88, green: 0.43, blue: 0.47, alpha: 1.0).cgColor,
                UIColor(red: 0.64, green: 0.21, blue: 0.36, alpha: 1.0).cgColor
            ]
        }
    }

    private func generateDescriptionText(forChallenge challenge: ChallengeLevel) -> String {
        if challenge == .relaxed {
            return "4x4 grid / 15s timer"
        } else {
            return "5x5 grid / 30s timer"
        }
    }
}
