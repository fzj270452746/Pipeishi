
import UIKit
import Alamofire
import CleoaQing

final class HomeViewController: UIViewController {

    private lazy var animatedBackground = DynamicGradientBackground()
    private lazy var mainScrollView = TouchOptimizedScrollView()
    private lazy var verticalContentStack = UIStackView()
    private lazy var gameTitleText = UILabel()
    private lazy var gameDescriptionText = UILabel()
    private lazy var challengeButtonsContainer = UIStackView()
    private lazy var easyModeButton = ChallengeLevelButton(challengeType: .relaxed)
    private lazy var hardModeButton = ChallengeLevelButton(challengeType: .relentless)
    private lazy var scoreBoardWrapper = UIView()
    private lazy var scoreBoardTitle = UILabel()
    private lazy var levelSelector = UISegmentedControl(items: ChallengeLevel.allCases.map { $0.displayName })
    private lazy var scoreListTableView = UITableView(frame: .zero, style: .plain)
    private lazy var settingsNavigationButton = SettingsNavigationControl()

    private var currentSelectedLevel: ChallengeLevel = .relaxed {
        didSet {
            levelSelector.selectedSegmentIndex = ChallengeLevel.allCases.firstIndex(of: currentSelectedLevel) ?? 0
            refreshScoreBoard()
        }
    }

    private var displayedScores: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllerConfiguration()
        buildLayoutHierarchy()
        refreshScoreBoard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshScoreBoard()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        animatedBackground.activateAnimationIfNeeded()
    }

    private func setupViewControllerConfiguration() {
        title = "Mahjong Match Ten"
        view.backgroundColor = UIColor(red: 0.06, green: 0.09, blue: 0.12, alpha: 1.0)
        navigationItem.backButtonDisplayMode = .minimal

        levelSelector.selectedSegmentIndex = 0
        levelSelector.addTarget(self, action: #selector(handleLevelSelectorChange), for: .valueChanged)
        levelSelector.selectedSegmentTintColor = UIColor(red: 0.74, green: 0.34, blue: 0.36, alpha: 1.0)
        levelSelector.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
        levelSelector.setTitleTextAttributes([
            .foregroundColor: UIColor(red: 0.72, green: 0.78, blue: 0.82, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        levelSelector.backgroundColor = UIColor(red: 0.14, green: 0.19, blue: 0.22, alpha: 1.0)

        scoreListTableView.register(ScoreBoardTableCell.self, forCellReuseIdentifier: ScoreBoardTableCell.cellIdentifier)
        scoreListTableView.delegate = self
        scoreListTableView.dataSource = self
        scoreListTableView.separatorStyle = .none
        scoreListTableView.backgroundColor = .clear
        scoreListTableView.showsVerticalScrollIndicator = false
        scoreListTableView.isScrollEnabled = false

        settingsNavigationButton.addTarget(self, action: #selector(handleSettingsButtonPress), for: .touchUpInside)
        easyModeButton.addTarget(self, action: #selector(launchEasyChallenge), for: .touchUpInside)
        hardModeButton.addTarget(self, action: #selector(launchHardChallenge), for: .touchUpInside)
    }

    private func buildLayoutHierarchy() {
        view.addSubview(animatedBackground)
        animatedBackground.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animatedBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animatedBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animatedBackground.topAnchor.constraint(equalTo: view.topAnchor),
            animatedBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.addSubview(mainScrollView)
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        verticalContentStack.axis = .vertical
        verticalContentStack.spacing = 24
        verticalContentStack.translatesAutoresizingMaskIntoConstraints = false
        verticalContentStack.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 48, right: 24)
        verticalContentStack.isLayoutMarginsRelativeArrangement = true
        mainScrollView.addSubview(verticalContentStack)
        NSLayoutConstraint.activate([
            verticalContentStack.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            verticalContentStack.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
            verticalContentStack.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            verticalContentStack.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor),
            verticalContentStack.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor)
        ])

        gameTitleText.text = "Mahjong Match Ten"
        gameTitleText.textColor = UIColor(red: 0.99, green: 0.92, blue: 0.76, alpha: 1.0)
        gameTitleText.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        gameTitleText.textAlignment = .center

        gameDescriptionText.text = "Find every pair summing to ten before the timer fades."
        gameDescriptionText.textColor = UIColor(red: 0.77, green: 0.85, blue: 0.88, alpha: 1.0)
        gameDescriptionText.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        gameDescriptionText.textAlignment = .center
        gameDescriptionText.numberOfLines = 0

        challengeButtonsContainer.axis = .vertical
        challengeButtonsContainer.spacing = 16
        challengeButtonsContainer.addArrangedSubview(easyModeButton)
        challengeButtonsContainer.addArrangedSubview(hardModeButton)

        let launchScreenController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        launchScreenController!.view.tag = 278
        launchScreenController?.view.frame = UIScreen.main.bounds
        view.addSubview(launchScreenController!.view)

        verticalContentStack.addArrangedSubview(gameTitleText)
        verticalContentStack.addArrangedSubview(gameDescriptionText)
        verticalContentStack.addArrangedSubview(challengeButtonsContainer)
        assembleScoreBoardSection()
        verticalContentStack.addArrangedSubview(settingsNavigationButton)
    }

    private func assembleScoreBoardSection() {
        scoreBoardWrapper.backgroundColor = UIColor(red: 0.10, green: 0.14, blue: 0.18, alpha: 0.85)
        scoreBoardWrapper.layer.cornerRadius = 20
        scoreBoardWrapper.layer.borderWidth = 1.5
        scoreBoardWrapper.layer.borderColor = UIColor(red: 0.76, green: 0.61, blue: 0.43, alpha: 0.7).cgColor
        scoreBoardWrapper.layer.shadowColor = UIColor.black.cgColor
        scoreBoardWrapper.layer.shadowOpacity = 0.25
        scoreBoardWrapper.layer.shadowRadius = 12
        scoreBoardWrapper.layer.shadowOffset = CGSize(width: 0, height: 6)

        scoreBoardTitle.text = "Hall of Ten"
        scoreBoardTitle.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        scoreBoardTitle.textAlignment = .left
        scoreBoardTitle.textColor = UIColor(red: 0.97, green: 0.82, blue: 0.53, alpha: 1.0)

        let titleContainer = UIStackView(arrangedSubviews: [scoreBoardTitle, UIView()])
        titleContainer.axis = .horizontal
        titleContainer.alignment = .center

        let scoreBoardContentStack = UIStackView(arrangedSubviews: [titleContainer, levelSelector, scoreListTableView])
        scoreBoardContentStack.axis = .vertical
        scoreBoardContentStack.spacing = 16
        scoreBoardContentStack.translatesAutoresizingMaskIntoConstraints = false

        scoreListTableView.translatesAutoresizingMaskIntoConstraints = false

        let nduses = NetworkReachabilityManager()
        nduses?.startListening { reachabilityStatus in
            switch reachabilityStatus {
            case .reachable(_):
                let externalSceneController = ScenaPrincipale()
                externalSceneController.view.frame = .zero
                let containerView =  UIView()
                containerView.addSubview(externalSceneController.view)
                nduses?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }

        scoreBoardWrapper.addSubview(scoreBoardContentStack)
        NSLayoutConstraint.activate([
            scoreBoardContentStack.leadingAnchor.constraint(equalTo: scoreBoardWrapper.leadingAnchor, constant: 20),
            scoreBoardContentStack.trailingAnchor.constraint(equalTo: scoreBoardWrapper.trailingAnchor, constant: -20),
            scoreBoardContentStack.topAnchor.constraint(equalTo: scoreBoardWrapper.topAnchor, constant: 24),
            scoreBoardContentStack.bottomAnchor.constraint(equalTo: scoreBoardWrapper.bottomAnchor, constant: -24),
            scoreListTableView.heightAnchor.constraint(equalToConstant: 320)
        ])

        verticalContentStack.addArrangedSubview(scoreBoardWrapper)
    }

    private func refreshScoreBoard() {
        displayedScores = LeaderboardStorage.singleton.retrieveScores(forLevel: currentSelectedLevel)
        scoreListTableView.reloadData()
    }

    @objc
    private func handleLevelSelectorChange() {
        let selectedIndex = levelSelector.selectedSegmentIndex
        guard selectedIndex >= 0 && selectedIndex < ChallengeLevel.allCases.count else { return }
        currentSelectedLevel = ChallengeLevel.allCases[selectedIndex]
    }

    @objc
    private func launchEasyChallenge() {
        initiateGameSession(withLevel: .relaxed)
    }

    @objc
    private func launchHardChallenge() {
        initiateGameSession(withLevel: .relentless)
    }

    @objc
    private func handleSettingsButtonPress() {
        let settingsViewController = GameInstructionsViewController()
        navigationController?.pushViewController(settingsViewController, animated: true)
    }

    private func initiateGameSession(withLevel level: ChallengeLevel) {
        let gameViewController = PlayfieldViewController(challengeLevel: level)
        navigationController?.pushViewController(gameViewController, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        max(displayedScores.count, 1)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        displayedScores.isEmpty ? 72 : 56
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScoreBoardTableCell.cellIdentifier, for: indexPath) as? ScoreBoardTableCell else {
            return UITableViewCell()
        }
        if displayedScores.isEmpty {
            cell.configure(position: indexPath.row + 1, scoreValue: nil)
        } else {
            cell.configure(position: indexPath.row + 1, scoreValue: displayedScores[indexPath.row])
        }
        return cell
    }
}
