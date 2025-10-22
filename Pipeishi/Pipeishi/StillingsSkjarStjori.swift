
import UIKit

final class GameInstructionsViewController: UIViewController {

    private lazy var animatedBackgroundView = DynamicGradientBackground()
    private lazy var contentScrollView = TouchOptimizedScrollView()
    private lazy var verticalStackContainer = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lore & Settings"
        setupBackgroundLayer()
        assembleContentLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        animatedBackgroundView.activateAnimationIfNeeded()
    }

    private func setupBackgroundLayer() {
        view.backgroundColor = UIColor(red: 0.07, green: 0.10, blue: 0.13, alpha: 1.0)
        view.addSubview(animatedBackgroundView)
        animatedBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animatedBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animatedBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animatedBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            animatedBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func assembleContentLayout() {
        contentScrollView.showsVerticalScrollIndicator = false
        view.addSubview(contentScrollView)
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        verticalStackContainer.axis = .vertical
        verticalStackContainer.spacing = 24
        verticalStackContainer.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 40, right: 24)
        verticalStackContainer.isLayoutMarginsRelativeArrangement = true

        contentScrollView.addSubview(verticalStackContainer)
        verticalStackContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStackContainer.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor),
            verticalStackContainer.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor),
            verticalStackContainer.topAnchor.constraint(equalTo: contentScrollView.topAnchor),
            verticalStackContainer.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor),
            verticalStackContainer.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor)
        ])

        verticalStackContainer.addArrangedSubview(createInformationPanel(headerText: "How to Play", contentLines: [
            "Each round surfaces a fresh spread of Mahjong tiles.",
            "Pick two tiles whose numbers add up to ten; matched tiles fade and free space.",
            "Clear every viable pair before the spirit timer burns out to gain +10 score.",
            "On Hard, the 5x5 grid hides more duplicates—track suits and values carefully."
        ]))

        verticalStackContainer.addArrangedSubview(createInformationPanel(headerText: "Difficulty Path", contentLines: [
            "Easy — 4x4 grid, 15 second timer, minimum of three ten-pairs.",
            "Hard — 5x5 grid, 30 second timer, minimum of five ten-pairs."
        ]))

        verticalStackContainer.addArrangedSubview(createInformationPanel(headerText: "Feedback & Support", contentLines: [
            "Got an idea for new tile flashes? Email support@matchten.studio.",
            "Include screenshots or recordings when possible—we respond within three business days."
        ]))

        verticalStackContainer.addArrangedSubview(createInformationPanel(headerText: "Privacy Oath", contentLines: [
            "We save only your leaderboard scores locally on device.",
            "No analytics, no telemetry. Delete the app to erase every trace."
        ]))
    }

    private func createInformationPanel(headerText: String, contentLines: [String]) -> UIView {
        let panelContainer = UIView()
        panelContainer.backgroundColor = UIColor(red: 0.11, green: 0.16, blue: 0.21, alpha: 0.85)
        panelContainer.layer.cornerRadius = 20
        panelContainer.layer.borderWidth = 1.2
        panelContainer.layer.borderColor = UIColor(red: 0.53, green: 0.67, blue: 0.72, alpha: 0.7).cgColor
        panelContainer.layer.shadowColor = UIColor.black.cgColor
        panelContainer.layer.shadowOpacity = 0.25
        panelContainer.layer.shadowRadius = 10
        panelContainer.layer.shadowOffset = CGSize(width: 0, height: 4)

        let headerLabel = UILabel()
        headerLabel.text = headerText
        headerLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        headerLabel.textColor = UIColor(red: 0.96, green: 0.87, blue: 0.65, alpha: 1.0)

        let contentTextStack = UIStackView()
        contentTextStack.axis = .vertical
        contentTextStack.spacing = 12

        for lineText in contentLines {
            let lineLabel = UILabel()
            lineLabel.text = lineText
            lineLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            lineLabel.textColor = UIColor(red: 0.78, green: 0.85, blue: 0.88, alpha: 1.0)
            lineLabel.numberOfLines = 0
            contentTextStack.addArrangedSubview(lineLabel)
        }

        let combinedStack = UIStackView(arrangedSubviews: [headerLabel, contentTextStack])
        combinedStack.axis = .vertical
        combinedStack.spacing = 16
        combinedStack.translatesAutoresizingMaskIntoConstraints = false

        panelContainer.addSubview(combinedStack)
        NSLayoutConstraint.activate([
            combinedStack.leadingAnchor.constraint(equalTo: panelContainer.leadingAnchor, constant: 20),
            combinedStack.trailingAnchor.constraint(equalTo: panelContainer.trailingAnchor, constant: -20),
            combinedStack.topAnchor.constraint(equalTo: panelContainer.topAnchor, constant: 22),
            combinedStack.bottomAnchor.constraint(equalTo: panelContainer.bottomAnchor, constant: -22)
        ])

        return panelContainer
    }
}
