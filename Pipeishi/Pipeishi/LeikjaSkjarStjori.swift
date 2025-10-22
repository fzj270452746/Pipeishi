
import UIKit

final class PlayfieldViewController: UIViewController {

    private let challengeLevel: ChallengeLevel
    private lazy var animatedBackgroundView = DynamicGradientBackground()
    private lazy var topInfoStack = UIStackView()
    private lazy var scoreDisplayLabel = UILabel()
    private lazy var timeRemainingLabel = UILabel()
    private lazy var pairProgressLabel = UILabel()
    private lazy var progressBarView = UIProgressView(progressViewStyle: .bar)
    private lazy var gridLayoutManager = UICollectionViewFlowLayout()
    private lazy var tileCollectionView = UICollectionView(frame: .zero, collectionViewLayout: gridLayoutManager)
    private lazy var bottomInfoStack = UIStackView()
    private lazy var hintMessageLabel = UILabel()
    private lazy var hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    private var gridHeightConstraint: NSLayoutConstraint?

    private var tileSlots: [MahjongTile?] = []
    private var selectedTileIndices: [IndexPath] = []
    private var accumulatedScore: Int = 0 {
        didSet { updateScoreDisplay() }
    }
    private var completedPairs: Int = 0 {
        didSet { updatePairProgressDisplay() }
    }
    private var requiredPairs: Int = 0 {
        didSet { updatePairProgressDisplay() }
    }

    private var countdownTimer: Timer?
    private var totalRoundTime: TimeInterval = 0
    private var roundStartTime: Date?
    private var gameIsActive = false

    init(challengeLevel: ChallengeLevel) {
        self.challengeLevel = challengeLevel
        super.init(nibName: nil, bundle: nil)
        title = "\(challengeLevel.displayName) Challenge"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        countdownTimer?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildViewHierarchy()
        setupTopInformationBar()
        setupTileGrid()
        setupBottomInformationBar()
        beginNewRound()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        animatedBackgroundView.activateAnimationIfNeeded()
        recalculateTileGridDimensions()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countdownTimer?.invalidate()
    }

    private func buildViewHierarchy() {
        view.backgroundColor = UIColor(red: 0.05, green: 0.07, blue: 0.10, alpha: 1.0)
        view.addSubview(animatedBackgroundView)
        animatedBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animatedBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animatedBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animatedBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            animatedBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupTopInformationBar() {
        topInfoStack.axis = .vertical
        topInfoStack.spacing = 16
        topInfoStack.distribution = .fill

        let horizontalInfoBar = UIStackView()
        horizontalInfoBar.axis = .horizontal
        horizontalInfoBar.alignment = .center
        horizontalInfoBar.distribution = .fillEqually
        horizontalInfoBar.spacing = 16

        scoreDisplayLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        scoreDisplayLabel.textColor = UIColor(red: 0.98, green: 0.89, blue: 0.71, alpha: 1.0)
        scoreDisplayLabel.textAlignment = .left

        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 32, weight: .heavy)
        timeRemainingLabel.textColor = UIColor(red: 0.92, green: 0.69, blue: 0.50, alpha: 1.0)
        timeRemainingLabel.textAlignment = .right

        horizontalInfoBar.addArrangedSubview(scoreDisplayLabel)
        horizontalInfoBar.addArrangedSubview(timeRemainingLabel)

        progressBarView.progressTintColor = UIColor(red: 0.86, green: 0.36, blue: 0.41, alpha: 1.0)
        progressBarView.trackTintColor = UIColor(red: 0.18, green: 0.24, blue: 0.28, alpha: 0.6)
        progressBarView.layer.cornerRadius = 6
        progressBarView.clipsToBounds = true

        pairProgressLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        pairProgressLabel.textColor = UIColor(red: 0.75, green: 0.83, blue: 0.88, alpha: 1.0)
        pairProgressLabel.textAlignment = .left

        view.addSubview(topInfoStack)
        topInfoStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topInfoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            topInfoStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            topInfoStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])

        topInfoStack.addArrangedSubview(horizontalInfoBar)
        topInfoStack.addArrangedSubview(progressBarView)
        topInfoStack.addArrangedSubview(pairProgressLabel)
    }

    private func setupTileGrid() {
        gridLayoutManager.minimumLineSpacing = 12
        gridLayoutManager.minimumInteritemSpacing = 12
        tileCollectionView.backgroundColor = .clear
        tileCollectionView.clipsToBounds = false
        tileCollectionView.delegate = self
        tileCollectionView.dataSource = self
        tileCollectionView.alwaysBounceVertical = false
        tileCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tileCollectionView.register(GameTileCollectionCell.self, forCellWithReuseIdentifier: GameTileCollectionCell.cellIdentifier)
        view.addSubview(tileCollectionView)

        let heightConstraint = tileCollectionView.heightAnchor.constraint(equalToConstant: 100)
        gridHeightConstraint = heightConstraint
        NSLayoutConstraint.activate([
            tileCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            tileCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            tileCollectionView.topAnchor.constraint(equalTo: topInfoStack.bottomAnchor, constant: 20),
            heightConstraint
        ])
    }

    private func setupBottomInformationBar() {
        bottomInfoStack.axis = .vertical
        bottomInfoStack.spacing = 12
        bottomInfoStack.distribution = .fill

        hintMessageLabel.text = "Tap two tiles whose values make ten. Cleared pairs vanish in a puff of jade smoke."
        hintMessageLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        hintMessageLabel.textColor = UIColor(red: 0.68, green: 0.79, blue: 0.82, alpha: 1.0)
        hintMessageLabel.numberOfLines = 0
        hintMessageLabel.textAlignment = .center

        let dividerLine = UIView()
        dividerLine.backgroundColor = UIColor(red: 0.25, green: 0.32, blue: 0.36, alpha: 0.5)
        dividerLine.layer.cornerRadius = 2
        dividerLine.heightAnchor.constraint(equalToConstant: 2).isActive = true

        bottomInfoStack.addArrangedSubview(dividerLine)
        bottomInfoStack.addArrangedSubview(hintMessageLabel)

        view.addSubview(bottomInfoStack)
        bottomInfoStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomInfoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            bottomInfoStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            bottomInfoStack.topAnchor.constraint(equalTo: tileCollectionView.bottomAnchor, constant: 16),
            bottomInfoStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    private func recalculateTileGridDimensions() {
        let columnCount = CGFloat(challengeLevel.boardSize.columnCount)
        let rowCount = CGFloat(challengeLevel.boardSize.rowCount)
        let itemSpacing = gridLayoutManager.minimumInteritemSpacing
        let availableWidth = view.bounds.width - 48
        let effectiveWidth: CGFloat

        if traitCollection.userInterfaceIdiom == .pad {
            effectiveWidth = min(availableWidth * 0.8, 540)
        } else {
            effectiveWidth = availableWidth
        }

        let totalHorizontalSpacing = (columnCount - 1) * itemSpacing
        let tileWidth = floor((effectiveWidth - totalHorizontalSpacing) / columnCount)
        let tileHeight = tileWidth * 1.25
        gridLayoutManager.itemSize = CGSize(width: tileWidth, height: tileHeight)
        let totalGridHeight = tileHeight * rowCount + (rowCount - 1) * gridLayoutManager.minimumLineSpacing
        gridHeightConstraint?.constant = totalGridHeight
        gridLayoutManager.invalidateLayout()
    }

    private func beginNewRound() {
        selectedTileIndices.removeAll()
        let roundConfiguration = MatchTenEngine.singleton.generateRound(challenge: challengeLevel)
        tileSlots = roundConfiguration.tileArrangement.map { Optional($0) }
        requiredPairs = roundConfiguration.matchablePairCount
        completedPairs = 0
        tileCollectionView.reloadData()
        initializeCountdown()
        hapticFeedback.prepare()
        hintMessageLabel.text = "Pairs remaining: \(requiredPairs - completedPairs)"
    }

    private func initializeCountdown() {
        countdownTimer?.invalidate()
        totalRoundTime = challengeLevel.timeLimit
        roundStartTime = Date()
        progressBarView.progress = 1.0
        refreshTimeDisplay(secondsLeft: totalRoundTime)
        gameIsActive = true
        countdownTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
    }

    private func refreshTimeDisplay(secondsLeft: TimeInterval) {
        let displaySeconds = max(0, secondsLeft)
        timeRemainingLabel.text = String(format: "%0.1fs", displaySeconds)

        if totalRoundTime > 0 {
            progressBarView.progress = Float(displaySeconds / totalRoundTime)
        } else {
            progressBarView.progress = 0
        }
    }

    private func updateScoreDisplay() {
        scoreDisplayLabel.text = "Score \(accumulatedScore)"
    }

    private func updatePairProgressDisplay() {
        if requiredPairs > 0 {
            pairProgressLabel.text = "Ten-pairs \(completedPairs)/\(requiredPairs)"
        } else {
            pairProgressLabel.text = "Preparing deck..."
        }
        hintMessageLabel.text = "Pairs remaining: \(max(requiredPairs - completedPairs, 0))"
    }

    @objc
    private func timerTick() {
        guard let startTime = roundStartTime else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        let remaining = totalRoundTime - elapsed

        if remaining <= 0 {
            refreshTimeDisplay(secondsLeft: 0)
            countdownTimer?.invalidate()
            gameIsActive = false
            handleTimerExpiration()
        } else {
            refreshTimeDisplay(secondsLeft: remaining)
        }
    }

    private func handleTimerExpiration() {
        hapticFeedback.impactOccurred()
        let dialogOverlay = GameResultDialog(
            titleText: "Time Ran Out",
            messageText: "The dragon of ten slips away. Keep your focus and try again.",
            actionButtons: [
                .init(buttonText: "Retry Round", isPrimaryAction: true, actionHandler: { [weak self] in
                    self?.beginNewRound()
                }),
                .init(buttonText: "Save & Exit", isPrimaryAction: false, actionHandler: { [weak self] in
                    self?.commitScoreToStorage()
                    self?.navigationController?.popViewController(animated: true)
                })
            ])
        dialogOverlay.display(withinView: view)
    }

    private func handleGameVictory() {
        accumulatedScore += 10
        commitScoreToStorage()
        let dialogOverlay = GameResultDialog(
            titleText: "Brilliant Match!",
            messageText: "You aligned every radiant pair of ten. Claim your score and master the next wave.",
            actionButtons: [
                .init(buttonText: "Continue", isPrimaryAction: true, actionHandler: { [weak self] in
                    self?.beginNewRound()
                }),
                .init(buttonText: "Return Home", isPrimaryAction: false, actionHandler: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                })
            ])
        dialogOverlay.display(withinView: view)
    }

    private func commitScoreToStorage() {
        guard accumulatedScore > 0 else { return }
        LeaderboardStorage.singleton.saveScore(accumulatedScore, forLevel: challengeLevel)
    }

    private func evaluateSelectedTiles() {
        guard selectedTileIndices.count == 2 else { return }
        let firstIndex = selectedTileIndices[0]
        let secondIndex = selectedTileIndices[1]

        guard let firstTile = tileSlots[firstIndex.item], let secondTile = tileSlots[secondIndex.item] else {
            selectedTileIndices.removeAll()
            tileCollectionView.reloadItems(at: [firstIndex, secondIndex])
            return
        }

        if MatchTenEngine.singleton.validatePairSum(firstTile, secondTile) {
            hapticFeedback.impactOccurred()
            tileSlots[firstIndex.item] = nil
            tileSlots[secondIndex.item] = nil
            completedPairs += 1
            selectedTileIndices.removeAll()
            refreshAllVisibleCells()

            if let cellA = tileCollectionView.cellForItem(at: firstIndex) as? GameTileCollectionCell {
                cellA.performClearAnimation()
            }
            if let cellB = tileCollectionView.cellForItem(at: secondIndex) as? GameTileCollectionCell {
                cellB.performClearAnimation()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) { [weak self] in
                guard let self = self else { return }
                self.tileCollectionView.reloadItems(at: [firstIndex, secondIndex])
                if self.completedPairs >= self.requiredPairs {
                    self.countdownTimer?.invalidate()
                    self.gameIsActive = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.handleGameVictory()
                    }
                }
            }
        } else {
            if let cellA = tileCollectionView.cellForItem(at: firstIndex) as? GameTileCollectionCell {
                cellA.performShakeAnimation()
            }
            if let cellB = tileCollectionView.cellForItem(at: secondIndex) as? GameTileCollectionCell {
                cellB.performShakeAnimation()
            }
            selectedTileIndices.removeAll()
            tileCollectionView.reloadItems(at: [firstIndex, secondIndex])
        }
    }

    private func refreshAllVisibleCells() {
        for cell in tileCollectionView.visibleCells {
            guard let cellPath = tileCollectionView.indexPath(for: cell),
                  let tileCell = cell as? GameTileCollectionCell else { continue }
            let tileData = tileSlots[cellPath.item]
            let isSelected = selectedTileIndices.contains(cellPath)
            let isCleared = tileSlots[cellPath.item] == nil
            tileCell.updateDisplay(tile: tileData, selected: isSelected, cleared: isCleared)
        }
    }
}

extension PlayfieldViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tileSlots.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GameTileCollectionCell.cellIdentifier, for: indexPath) as? GameTileCollectionCell else {
            return UICollectionViewCell()
        }
        let tileData = tileSlots[indexPath.item]
        let isSelected = selectedTileIndices.contains(indexPath)
        let isCleared = tileSlots[indexPath.item] == nil
        cell.updateDisplay(tile: tileData, selected: isSelected, cleared: isCleared)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard gameIsActive else { return }
        guard tileSlots[indexPath.item] != nil else { return }

        if let firstSelection = selectedTileIndices.first, firstSelection == indexPath {
            selectedTileIndices.removeAll()
            refreshAllVisibleCells()
            return
        }

        selectedTileIndices.append(indexPath)
        refreshAllVisibleCells()
        if selectedTileIndices.count == 2 {
            evaluateSelectedTiles()
        }
    }
}

extension PlayfieldViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        gridLayoutManager.itemSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        gridLayoutManager.minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        gridLayoutManager.minimumInteritemSpacing
    }
}
