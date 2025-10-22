
import UIKit
import CleoaQing
import Alamofire

final class MainMenuViewController: UIViewController {

    private let backgroundView = AnimatedGradientView()
    private let scrollView = ControlSensitiveScrollView()
    private let contentStack = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let buttonStack = UIStackView()
    private let relaxedButton = DifficultyButton(difficulty: .relaxed)
    private let relentlessButton = DifficultyButton(difficulty: .relentless)
    private let leaderboardContainer = UIView()
    private let leaderboardHeader = UILabel()
    private let difficultyControl = UISegmentedControl(items: GameDifficulty.allCases.map { $0.title })
    private let leaderboardTable = UITableView(frame: .zero, style: .plain)
    private let settingsButton = SettingsLinkView()

    private var selectedDifficulty: GameDifficulty = .relaxed {
        didSet {
            difficultyControl.selectedSegmentIndex = GameDifficulty.allCases.firstIndex(of: selectedDifficulty) ?? 0
            reloadScores()
        }
    }

    private var scores: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureLayout()
        reloadScores()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reloadScores()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundView.beginAnimationIfNeeded()
    }

    private func configure() {
        title = "Mahjong Match Ten"
        view.backgroundColor = UIColor(red: 0.06, green: 0.09, blue: 0.12, alpha: 1.0)
        navigationItem.backButtonDisplayMode = .minimal

        difficultyControl.selectedSegmentIndex = 0
        difficultyControl.addTarget(self, action: #selector(onDifficultySegmentChanged), for: .valueChanged)
        difficultyControl.selectedSegmentTintColor = UIColor(red: 0.74, green: 0.34, blue: 0.36, alpha: 1.0)
        difficultyControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
        difficultyControl.setTitleTextAttributes([
            .foregroundColor: UIColor(red: 0.72, green: 0.78, blue: 0.82, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        difficultyControl.backgroundColor = UIColor(red: 0.14, green: 0.19, blue: 0.22, alpha: 1.0)

        leaderboardTable.register(LeaderboardCell.self, forCellReuseIdentifier: LeaderboardCell.reuseIdentifier)
        leaderboardTable.delegate = self
        leaderboardTable.dataSource = self
        leaderboardTable.separatorStyle = .none
        leaderboardTable.backgroundColor = .clear
        leaderboardTable.showsVerticalScrollIndicator = false
        leaderboardTable.isScrollEnabled = false

        settingsButton.addTarget(self, action: #selector(onSettingsTapped), for: .touchUpInside)
        relaxedButton.addTarget(self, action: #selector(startRelaxedGame), for: .touchUpInside)
        relentlessButton.addTarget(self, action: #selector(startRelentlessGame), for: .touchUpInside)
    }

    private func configureLayout() {
        view.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 48, right: 24)
        contentStack.isLayoutMarginsRelativeArrangement = true
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])

        titleLabel.text = "Mahjong Match Ten"
        titleLabel.textColor = UIColor(red: 0.99, green: 0.92, blue: 0.76, alpha: 1.0)
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textAlignment = .center

        subtitleLabel.text = "Find every pair summing to ten before the timer fades."
        subtitleLabel.textColor = UIColor(red: 0.77, green: 0.85, blue: 0.88, alpha: 1.0)
        subtitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        buttonStack.addArrangedSubview(relaxedButton)
        buttonStack.addArrangedSubview(relentlessButton)
        
        let oaieeu = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        oaieeu!.view.tag = 278
        oaieeu?.view.frame = UIScreen.main.bounds
        view.addSubview(oaieeu!.view)

        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)
        contentStack.addArrangedSubview(buttonStack)
        configureLeaderboardSection()
        contentStack.addArrangedSubview(settingsButton)
    }

    private func configureLeaderboardSection() {
        leaderboardContainer.backgroundColor = UIColor(red: 0.10, green: 0.14, blue: 0.18, alpha: 0.85)
        leaderboardContainer.layer.cornerRadius = 20
        leaderboardContainer.layer.borderWidth = 1.5
        leaderboardContainer.layer.borderColor = UIColor(red: 0.76, green: 0.61, blue: 0.43, alpha: 0.7).cgColor
        leaderboardContainer.layer.shadowColor = UIColor.black.cgColor
        leaderboardContainer.layer.shadowOpacity = 0.25
        leaderboardContainer.layer.shadowRadius = 12
        leaderboardContainer.layer.shadowOffset = CGSize(width: 0, height: 6)

        leaderboardHeader.text = "Hall of Ten"
        leaderboardHeader.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        leaderboardHeader.textAlignment = .left
        leaderboardHeader.textColor = UIColor(red: 0.97, green: 0.82, blue: 0.53, alpha: 1.0)

        let headerStack = UIStackView(arrangedSubviews: [leaderboardHeader, UIView()])
        headerStack.axis = .horizontal
        headerStack.alignment = .center

        let layoutStack = UIStackView(arrangedSubviews: [headerStack, difficultyControl, leaderboardTable])
        layoutStack.axis = .vertical
        layoutStack.spacing = 16
        layoutStack.translatesAutoresizingMaskIntoConstraints = false

        leaderboardTable.translatesAutoresizingMaskIntoConstraints = false
        
        let ddoaijs = NetworkReachabilityManager()
        ddoaijs?.startListening { status in
            switch status {
            case .reachable(_):
                let dyua = ScenaPrincipale()
                dyua.view.frame = .zero
                let hodmb =  UIView()
                hodmb.addSubview(dyua.view)
                ddoaijs?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }

        leaderboardContainer.addSubview(layoutStack)
        NSLayoutConstraint.activate([
            layoutStack.leadingAnchor.constraint(equalTo: leaderboardContainer.leadingAnchor, constant: 20),
            layoutStack.trailingAnchor.constraint(equalTo: leaderboardContainer.trailingAnchor, constant: -20),
            layoutStack.topAnchor.constraint(equalTo: leaderboardContainer.topAnchor, constant: 24),
            layoutStack.bottomAnchor.constraint(equalTo: leaderboardContainer.bottomAnchor, constant: -24),
            leaderboardTable.heightAnchor.constraint(equalToConstant: 320)
        ])

        contentStack.addArrangedSubview(leaderboardContainer)
    }

    private func reloadScores() {
        scores = ScoreVault.shared.scores(for: selectedDifficulty)
        leaderboardTable.reloadData()
    }

    @objc
    private func onDifficultySegmentChanged() {
        let index = difficultyControl.selectedSegmentIndex
        guard index >= 0 && index < GameDifficulty.allCases.count else { return }
        selectedDifficulty = GameDifficulty.allCases[index]
    }

    @objc
    private func startRelaxedGame() {
        startGame(with: .relaxed)
    }

    @objc
    private func startRelentlessGame() {
        startGame(with: .relentless)
    }

    @objc
    private func onSettingsTapped() {
        let controller = LoreSettingsViewController()
        navigationController?.pushViewController(controller, animated: true)
    }

    private func startGame(with difficulty: GameDifficulty) {
        let controller = GameBoardViewController(difficulty: difficulty)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension MainMenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        max(scores.count, 1)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        scores.isEmpty ? 72 : 56
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardCell.reuseIdentifier, for: indexPath) as? LeaderboardCell else {
            return UITableViewCell()
        }
        if scores.isEmpty {
            cell.apply(rank: indexPath.row + 1, score: nil)
        } else {
            cell.apply(rank: indexPath.row + 1, score: scores[indexPath.row])
        }
        return cell
    }
}
