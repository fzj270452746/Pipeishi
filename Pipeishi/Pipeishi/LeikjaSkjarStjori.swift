//
//  GameBoardViewController.swift
//  Pipeishi
//
//  Refactored by Codex on 10/21/25.
//

import UIKit

final class GameBoardViewController: UIViewController {

    private let difficulty: GameDifficulty
    private let backgroundView = AnimatedGradientView()
    private let headerStack = UIStackView()
    private let scoreLabel = UILabel()
    private let timerLabel = UILabel()
    private let pairsLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let collectionLayout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
    private let footerStack = UIStackView()
    private let instructionsLabel = UILabel()
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private var collectionHeightConstraint: NSLayoutConstraint?

    private var slots: [TileCard?] = []
    private var selectedIndices: [IndexPath] = []
    private var totalScore: Int = 0 {
        didSet { updateScoreLabel() }
    }
    private var foundPairs: Int = 0 {
        didSet { updatePairLabel() }
    }
    private var targetPairs: Int = 0 {
        didSet { updatePairLabel() }
    }

    private var timer: Timer?
    private var roundDuration: TimeInterval = 0
    private var roundStart: Date?
    private var isRoundActive = false

    init(difficulty: GameDifficulty) {
        self.difficulty = difficulty
        super.init(nibName: nil, bundle: nil)
        title = "\(difficulty.title) Challenge"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        timer?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureHeader()
        configureCollectionView()
        configureFooter()
        startRound()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundView.beginAnimationIfNeeded()
        updateCollectionSizing()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    private func configureLayout() {
        view.backgroundColor = UIColor(red: 0.05, green: 0.07, blue: 0.10, alpha: 1.0)
        view.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureHeader() {
        headerStack.axis = .vertical
        headerStack.spacing = 16
        headerStack.distribution = .fill

        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.distribution = .fillEqually
        topRow.spacing = 16

        scoreLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        scoreLabel.textColor = UIColor(red: 0.98, green: 0.89, blue: 0.71, alpha: 1.0)
        scoreLabel.textAlignment = .left

        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 32, weight: .heavy)
        timerLabel.textColor = UIColor(red: 0.92, green: 0.69, blue: 0.50, alpha: 1.0)
        timerLabel.textAlignment = .right

        topRow.addArrangedSubview(scoreLabel)
        topRow.addArrangedSubview(timerLabel)

        progressView.progressTintColor = UIColor(red: 0.86, green: 0.36, blue: 0.41, alpha: 1.0)
        progressView.trackTintColor = UIColor(red: 0.18, green: 0.24, blue: 0.28, alpha: 0.6)
        progressView.layer.cornerRadius = 6
        progressView.clipsToBounds = true

        pairsLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        pairsLabel.textColor = UIColor(red: 0.75, green: 0.83, blue: 0.88, alpha: 1.0)
        pairsLabel.textAlignment = .left

        view.addSubview(headerStack)
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])

        headerStack.addArrangedSubview(topRow)
        headerStack.addArrangedSubview(progressView)
        headerStack.addArrangedSubview(pairsLabel)
    }

    private func configureCollectionView() {
        collectionLayout.minimumLineSpacing = 12
        collectionLayout.minimumInteritemSpacing = 12
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TileCell.self, forCellWithReuseIdentifier: TileCell.reuseIdentifier)
        view.addSubview(collectionView)

        let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 100)
        collectionHeightConstraint = heightConstraint
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            collectionView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 20),
            heightConstraint
        ])
    }

    private func configureFooter() {
        footerStack.axis = .vertical
        footerStack.spacing = 12
        footerStack.distribution = .fill

        instructionsLabel.text = "Tap two tiles whose values make ten. Cleared pairs vanish in a puff of jade smoke."
        instructionsLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        instructionsLabel.textColor = UIColor(red: 0.68, green: 0.79, blue: 0.82, alpha: 1.0)
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textAlignment = .center

        let separator = UIView()
        separator.backgroundColor = UIColor(red: 0.25, green: 0.32, blue: 0.36, alpha: 0.5)
        separator.layer.cornerRadius = 2
        separator.heightAnchor.constraint(equalToConstant: 2).isActive = true

        footerStack.addArrangedSubview(separator)
        footerStack.addArrangedSubview(instructionsLabel)

        view.addSubview(footerStack)
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            footerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            footerStack.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            footerStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    private func updateCollectionSizing() {
        let columns = CGFloat(difficulty.grid.columns)
        let rows = CGFloat(difficulty.grid.rows)
        let spacing = collectionLayout.minimumInteritemSpacing
        let boundsWidth = view.bounds.width - 48
        let targetWidth: CGFloat
        if traitCollection.userInterfaceIdiom == .pad {
            targetWidth = min(boundsWidth * 0.8, 540)
        } else {
            targetWidth = boundsWidth
        }
        let totalSpacing = (columns - 1) * spacing
        let cellWidth = floor((targetWidth - totalSpacing) / columns)
        let cellHeight = cellWidth * 1.25
        collectionLayout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        let collectionHeight = cellHeight * rows + (rows - 1) * collectionLayout.minimumLineSpacing
        collectionHeightConstraint?.constant = collectionHeight
        collectionLayout.invalidateLayout()
    }

    private func startRound() {
        selectedIndices.removeAll()
        let snapshot = GameEngine.shared.buildRound(for: difficulty)
        slots = snapshot.tiles.map { Optional($0) }
        targetPairs = snapshot.availablePairs
        foundPairs = 0
        collectionView.reloadData()
        resetTimer()
        feedbackGenerator.prepare()
        instructionsLabel.text = "Pairs remaining: \(targetPairs - foundPairs)"
    }

    private func resetTimer() {
        timer?.invalidate()
        roundDuration = difficulty.roundDuration
        roundStart = Date()
        progressView.progress = 1.0
        updateTimerLabel(remaining: roundDuration)
        isRoundActive = true
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(onTick), userInfo: nil, repeats: true)
    }

    private func updateTimerLabel(remaining: TimeInterval) {
        let seconds = max(0, remaining)
        timerLabel.text = String(format: "%0.1fs", seconds)
        if roundDuration > 0 {
            progressView.progress = Float(seconds / roundDuration)
        } else {
            progressView.progress = 0
        }
    }

    private func updateScoreLabel() {
        scoreLabel.text = "Score \(totalScore)"
    }

    private func updatePairLabel() {
        if targetPairs > 0 {
            pairsLabel.text = "Ten-pairs \(foundPairs)/\(targetPairs)"
        } else {
            pairsLabel.text = "Preparing deck..."
        }
        instructionsLabel.text = "Pairs remaining: \(max(targetPairs - foundPairs, 0))"
    }

    @objc
    private func onTick() {
        guard let start = roundStart else { return }
        let elapsed = Date().timeIntervalSince(start)
        let remaining = roundDuration - elapsed
        if remaining <= 0 {
            updateTimerLabel(remaining: 0)
            timer?.invalidate()
            isRoundActive = false
            handleTimeExpired()
        } else {
            updateTimerLabel(remaining: remaining)
        }
    }

    private func handleTimeExpired() {
        feedbackGenerator.impactOccurred()
        let overlay = ActionOverlayView(
            title: "Time Ran Out",
            message: "The dragon of ten slips away. Keep your focus and try again.",
            actions: [
                .init(title: "Retry Round", isPrimary: true, handler: { [weak self] in
                    self?.startRound()
                }),
                .init(title: "Save & Exit", isPrimary: false, handler: { [weak self] in
                    self?.persistScore()
                    self?.navigationController?.popViewController(animated: true)
                })
            ])
        overlay.present(in: view)
    }

    private func handleVictory() {
        totalScore += 10
        persistScore()
        let overlay = ActionOverlayView(
            title: "Brilliant Match!",
            message: "You aligned every radiant pair of ten. Claim your score and master the next wave.",
            actions: [
                .init(title: "Continue", isPrimary: true, handler: { [weak self] in
                    self?.startRound()
                }),
                .init(title: "Return Home", isPrimary: false, handler: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                })
            ])
        overlay.present(in: view)
    }

    private func persistScore() {
        guard totalScore > 0 else { return }
        ScoreVault.shared.persist(score: totalScore, difficulty: difficulty)
    }

    private func processSelection() {
        guard selectedIndices.count == 2 else { return }
        let first = selectedIndices[0]
        let second = selectedIndices[1]

        guard let tileA = slots[first.item], let tileB = slots[second.item] else {
            selectedIndices.removeAll()
            collectionView.reloadItems(at: [first, second])
            return
        }

        if GameEngine.shared.makesTen(tileA, tileB) {
            feedbackGenerator.impactOccurred()
            slots[first.item] = nil
            slots[second.item] = nil
            foundPairs += 1
            selectedIndices.removeAll()
            updateVisibleCells()

            if let cellA = collectionView.cellForItem(at: first) as? TileCell {
                cellA.playClearAnimation()
            }
            if let cellB = collectionView.cellForItem(at: second) as? TileCell {
                cellB.playClearAnimation()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) { [weak self] in
                guard let self = self else { return }
                self.collectionView.reloadItems(at: [first, second])
                if self.foundPairs >= self.targetPairs {
                    self.timer?.invalidate()
                    self.isRoundActive = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.handleVictory()
                    }
                }
            }
        } else {
            if let cellA = collectionView.cellForItem(at: first) as? TileCell {
                cellA.shake()
            }
            if let cellB = collectionView.cellForItem(at: second) as? TileCell {
                cellB.shake()
            }
            selectedIndices.removeAll()
            collectionView.reloadItems(at: [first, second])
        }
    }

    private func updateVisibleCells() {
        for cell in collectionView.visibleCells {
            guard let index = collectionView.indexPath(for: cell),
                  let tileCell = cell as? TileCell else { continue }
            let tile = slots[index.item]
            let isSelected = selectedIndices.contains(index)
            let isCleared = slots[index.item] == nil
            tileCell.update(with: tile, isSelected: isSelected, isCleared: isCleared)
        }
    }
}

extension GameBoardViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        slots.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TileCell.reuseIdentifier, for: indexPath) as? TileCell else {
            return UICollectionViewCell()
        }
        let tile = slots[indexPath.item]
        let isSelected = selectedIndices.contains(indexPath)
        let isCleared = slots[indexPath.item] == nil
        cell.update(with: tile, isSelected: isSelected, isCleared: isCleared)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard isRoundActive else { return }
        guard slots[indexPath.item] != nil else { return }

        if let first = selectedIndices.first, first == indexPath {
            selectedIndices.removeAll()
            updateVisibleCells()
            return
        }

        selectedIndices.append(indexPath)
        updateVisibleCells()
        if selectedIndices.count == 2 {
            processSelection()
        }
    }
}

extension GameBoardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionLayout.itemSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        collectionLayout.minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        collectionLayout.minimumInteritemSpacing
    }
}
