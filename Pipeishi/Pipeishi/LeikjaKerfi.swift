//
//  LeikjaKerfi.swift
//  Pipeishi
//
//  Refactored by Codex on 10/21/25.
//

import UIKit

// MARK: - Tile Domain

enum TileSet: CaseIterable {
    case blossom
    case lantern
    case tide

    var accent: UIColor {
        switch self {
        case .blossom:
            return UIColor(red: 0.90, green: 0.28, blue: 0.38, alpha: 1.0)
        case .lantern:
            return UIColor(red: 0.17, green: 0.57, blue: 0.86, alpha: 1.0)
        case .tide:
            return UIColor(red: 0.21, green: 0.67, blue: 0.51, alpha: 1.0)
        }
    }

    func assetName(for value: Int) -> String {
        return "\(assetPrefix)-\(value)"
    }

    private var assetPrefix: String {
        switch self {
        case .blossom:
            return "jeiu"
        case .lantern:
            return "zghs"
        case .tide:
            return "gsuu"
        }
    }
}

struct TileCard: Hashable {
    let id: UUID
    let tileSet: TileSet
    let value: Int

    init(set: TileSet, value: Int, id: UUID = UUID()) {
        self.id = id
        self.tileSet = set
        self.value = value
    }

    var imageName: String {
        return tileSet.assetName(for: value)
    }
}

// MARK: - Difficulty & Session Models

struct GridSize {
    let rows: Int
    let columns: Int

    var itemCount: Int { rows * columns }
}

enum GameDifficulty: CaseIterable {
    case relaxed
    case relentless

    var title: String {
        switch self {
        case .relaxed:
            return "Easy"
        case .relentless:
            return "Hard"
        }
    }

    var grid: GridSize {
        switch self {
        case .relaxed:
            return GridSize(rows: 4, columns: 4)
        case .relentless:
            return GridSize(rows: 5, columns: 5)
        }
    }

    var roundDuration: TimeInterval {
        switch self {
        case .relaxed:
            return 15
        case .relentless:
            return 30
        }
    }

    var minimumPairQuota: Int {
        switch self {
        case .relaxed:
            return 3
        case .relentless:
            return 5
        }
    }

    var maximumPairQuota: Int {
        switch self {
        case .relaxed:
            return 6
        case .relentless:
            return 10
        }
    }
}

struct RoundSnapshot {
    let tiles: [TileCard]
    let availablePairs: Int
}

// MARK: - Score Storage

final class ScoreVault {
    static let shared = ScoreVault()

    private let storageKey = "match_ten_saves"
    private let capacity = 20
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func scores(for difficulty: GameDifficulty) -> [Int] {
        let key = bucketKey(for: difficulty)
        return defaults.array(forKey: key) as? [Int] ?? []
    }

    @discardableResult
    func persist(score: Int, difficulty: GameDifficulty) -> [Int] {
        let key = bucketKey(for: difficulty)
        var existing = defaults.array(forKey: key) as? [Int] ?? []
        existing.append(score)
        existing.sort(by: >)
        if existing.count > capacity {
            existing = Array(existing.prefix(capacity))
        }
        defaults.set(existing, forKey: key)
        return existing
    }

    private func bucketKey(for difficulty: GameDifficulty) -> String {
        return "\(storageKey)_\(difficulty.title)"
    }
}

// MARK: - Game Engine

final class GameEngine {
    static let shared = GameEngine()

    private init() {}

    func buildRound(for difficulty: GameDifficulty) -> RoundSnapshot {
        let requiredTiles = difficulty.grid.itemCount
        var attempts = 0
        let maxAttempts = 200

        while attempts < maxAttempts {
            let deck = makeDeck().shuffled()
            let selection = Array(deck.prefix(requiredTiles))
            let pairs = countValidPairs(in: selection)

            if pairs >= difficulty.minimumPairQuota && pairs <= difficulty.maximumPairQuota {
                return RoundSnapshot(tiles: selection.shuffled(), availablePairs: pairs)
            }

            attempts += 1
        }

        let fallback = Array(makeDeck().shuffled().prefix(requiredTiles))
        return RoundSnapshot(tiles: fallback, availablePairs: countValidPairs(in: fallback))
    }

    func makesTen(_ tileA: TileCard, _ tileB: TileCard) -> Bool {
        return tileA.value + tileB.value == 10
    }

    func countValidPairs(in tiles: [TileCard]) -> Int {
        let grouped = Dictionary(grouping: tiles, by: { $0.value })
        var pairs = 0

        for value in 1...4 {
            let complement = 10 - value
            let countA = grouped[value]?.count ?? 0
            let countB = grouped[complement]?.count ?? 0
            pairs += min(countA, countB)
        }

        let fives = grouped[5]?.count ?? 0
        pairs += fives / 2

        return pairs
    }

    private func makeDeck() -> [TileCard] {
        TileSet.allCases.flatMap { set in
            (1...9).map { TileCard(set: set, value: $0) }
        }
    }
}
