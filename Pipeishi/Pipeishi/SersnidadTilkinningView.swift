
import UIKit

final class GameResultDialog: UIView {

    struct DialogAction {
        let buttonText: String
        let isPrimaryAction: Bool
        let actionHandler: (() -> Void)?
    }

    private lazy var blurBackdropView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private lazy var dialogContainer = UIView()
    private lazy var dialogTitleLabel = UILabel()
    private lazy var dialogMessageLabel = UILabel()
    private lazy var actionButtonStack = UIStackView()
    private var configuredActions: [DialogAction] = []

    init(titleText: String, messageText: String, actionButtons: [DialogAction]) {
        self.configuredActions = actionButtons
        super.init(frame: .zero)
        assembleDialog(titleText: titleText, messageText: messageText)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func display(withinView hostView: UIView) {
        hostView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: hostView.leadingAnchor),
            trailingAnchor.constraint(equalTo: hostView.trailingAnchor),
            topAnchor.constraint(equalTo: hostView.topAnchor),
            bottomAnchor.constraint(equalTo: hostView.bottomAnchor)
        ])

        alpha = 0
        transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.transform = .identity
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }

    private func assembleDialog(titleText: String, messageText: String) {
        backgroundColor = UIColor.black.withAlphaComponent(0.45)
        addSubview(blurBackdropView)
        blurBackdropView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurBackdropView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurBackdropView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurBackdropView.topAnchor.constraint(equalTo: topAnchor),
            blurBackdropView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        dialogContainer.backgroundColor = UIColor(red: 0.12, green: 0.17, blue: 0.22, alpha: 0.96)
        dialogContainer.layer.cornerRadius = 24
        dialogContainer.layer.borderWidth = 1.6
        dialogContainer.layer.borderColor = UIColor(red: 0.78, green: 0.62, blue: 0.38, alpha: 0.8).cgColor
        addSubview(dialogContainer)
        dialogContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dialogContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            dialogContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            dialogContainer.widthAnchor.constraint(equalTo: widthAnchor, multiplier: traitCollection.userInterfaceIdiom == .pad ? 0.45 : 0.8)
        ])

        dialogTitleLabel.text = titleText
        dialogTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        dialogTitleLabel.textColor = UIColor(red: 0.98, green: 0.91, blue: 0.73, alpha: 1.0)
        dialogTitleLabel.textAlignment = .center
        dialogTitleLabel.numberOfLines = 2

        dialogMessageLabel.text = messageText
        dialogMessageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        dialogMessageLabel.textColor = UIColor(red: 0.77, green: 0.85, blue: 0.88, alpha: 1.0)
        dialogMessageLabel.textAlignment = .center
        dialogMessageLabel.numberOfLines = 0

        actionButtonStack.axis = .vertical
        actionButtonStack.spacing = 12

        let dialogContentStack = UIStackView(arrangedSubviews: [dialogTitleLabel, dialogMessageLabel, actionButtonStack])
        dialogContentStack.axis = .vertical
        dialogContentStack.spacing = 20
        dialogContentStack.translatesAutoresizingMaskIntoConstraints = false
        dialogContainer.addSubview(dialogContentStack)
        NSLayoutConstraint.activate([
            dialogContentStack.leadingAnchor.constraint(equalTo: dialogContainer.leadingAnchor, constant: 24),
            dialogContentStack.trailingAnchor.constraint(equalTo: dialogContainer.trailingAnchor, constant: -24),
            dialogContentStack.topAnchor.constraint(equalTo: dialogContainer.topAnchor, constant: 28),
            dialogContentStack.bottomAnchor.constraint(equalTo: dialogContainer.bottomAnchor, constant: -28)
        ])

        populateActionButtons()
    }

    private func populateActionButtons() {
        guard !configuredActions.isEmpty else { return }
        actionButtonStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (buttonIndex, action) in configuredActions.enumerated() {
            let actionButton = UIButton(type: .system)
            actionButton.layer.cornerRadius = 16
            actionButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
            actionButton.setTitle(action.buttonText, for: .normal)
            actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            actionButton.addTarget(self, action: #selector(handleButtonPress(_:)), for: .touchUpInside)
            actionButton.tag = buttonIndex

            if action.isPrimaryAction {
                actionButton.backgroundColor = UIColor(red: 0.86, green: 0.34, blue: 0.34, alpha: 1.0)
                actionButton.setTitleColor(.white, for: .normal)
            } else {
                actionButton.layer.borderWidth = 1.2
                actionButton.layer.borderColor = UIColor(red: 0.64, green: 0.73, blue: 0.78, alpha: 1.0).cgColor
                actionButton.setTitleColor(UIColor(red: 0.80, green: 0.88, blue: 0.90, alpha: 1.0), for: .normal)
            }

            actionButtonStack.addArrangedSubview(actionButton)
        }
    }

    @objc
    private func handleButtonPress(_ sender: UIButton) {
        guard sender.tag < configuredActions.count else {
            hide()
            return
        }
        let selectedAction = configuredActions[sender.tag]
        hide()
        selectedAction.actionHandler?()
    }
}
