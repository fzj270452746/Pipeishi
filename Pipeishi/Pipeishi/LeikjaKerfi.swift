
import UIKit

// MARK: - Mahjong Tile Types

enum MahjongSuit: Int, CaseIterable {
    case blossom = 0
    case lantern = 1
    case tide = 2

    var themeColor: UIColor {
        let colors: [UIColor] = [
            UIColor(red: 0.90, green: 0.28, blue: 0.38, alpha: 1.0),
            UIColor(red: 0.17, green: 0.57, blue: 0.86, alpha: 1.0),
            UIColor(red: 0.21, green: 0.67, blue: 0.51, alpha: 1.0)
        ]
        return colors[rawValue]
    }

    func imageIdentifier(tileValue: Int) -> String {
        let prefixes = ["jeiu", "zghs", "gsuu"]
        return "\(prefixes[rawValue])-\(tileValue)"
    }
}

struct MahjongTile: Hashable {
    let uniqueIdentifier: UUID
    let suit: MahjongSuit
    let numericValue: Int

    init(suitType: MahjongSuit, number: Int, identifier: UUID = UUID()) {
        self.uniqueIdentifier = identifier
        self.suit = suitType
        self.numericValue = number
    }

    var assetImageName: String {
        suit.imageIdentifier(tileValue: numericValue)
    }
}

// MARK: - Game Configuration Models

struct BoardDimensions {
    let rowCount: Int
    let columnCount: Int

    var totalCells: Int {
        rowCount * columnCount
    }
}

enum ChallengeLevel: CaseIterable {
    case relaxed
    case relentless

    var displayName: String {
        self == .relaxed ? "Easy" : "Hard"
    }

    var boardSize: BoardDimensions {
        self == .relaxed ? BoardDimensions(rowCount: 4, columnCount: 4) : BoardDimensions(rowCount: 5, columnCount: 5)
    }

    var timeLimit: TimeInterval {
        self == .relaxed ? 15 : 30
    }

    var pairRequirementMin: Int {
        self == .relaxed ? 3 : 5
    }

    var pairRequirementMax: Int {
        self == .relaxed ? 6 : 10
    }
}

struct GameRound {
    let tileArrangement: [MahjongTile]
    let matchablePairCount: Int
}

// MARK: - Score Persistence Manager

final class LeaderboardStorage {
    static let singleton = LeaderboardStorage()

    private let storageIdentifier = "match_ten_saves"
    private let maximumEntries = 20
    private let userPreferences: UserDefaults

    private init(preferences: UserDefaults = .standard) {
        self.userPreferences = preferences
    }

    func retrieveScores(forLevel level: ChallengeLevel) -> [Int] {
        let storageKey = constructKey(level: level)
        return userPreferences.array(forKey: storageKey) as? [Int] ?? []
    }

    @discardableResult
    func saveScore(_ scoreValue: Int, forLevel level: ChallengeLevel) -> [Int] {
        let storageKey = constructKey(level: level)
        var scoreList = userPreferences.array(forKey: storageKey) as? [Int] ?? []
        scoreList.append(scoreValue)
        scoreList.sort { $0 > $1 }

        if scoreList.count > maximumEntries {
            scoreList = Array(scoreList[..<maximumEntries])
        }

        userPreferences.set(scoreList, forKey: storageKey)
        return scoreList
    }

    private func constructKey(level: ChallengeLevel) -> String {
        "\(storageIdentifier)_\(level.displayName)"
    }
}

// MARK: - Game Logic Engine

final class MatchTenEngine {
    static let singleton = MatchTenEngine()

    private init() {}

    func generateRound(challenge: ChallengeLevel) -> GameRound {
        let tilesNeeded = challenge.boardSize.totalCells
        var attemptCounter = 0
        let maximumAttempts = 200

        while attemptCounter < maximumAttempts {
            let fullDeck = createFullDeck()
            let shuffledDeck = fullDeck.shuffled()
            let selectedTiles = Array(shuffledDeck.prefix(tilesNeeded))
            let matchableCount = calculateMatchablePairs(tiles: selectedTiles)

            if matchableCount >= challenge.pairRequirementMin && matchableCount <= challenge.pairRequirementMax {
                return GameRound(tileArrangement: selectedTiles.shuffled(), matchablePairCount: matchableCount)
            }

            attemptCounter += 1
        }

        let fallbackDeck = createFullDeck().shuffled()
        let fallbackTiles = Array(fallbackDeck.prefix(tilesNeeded))
        return GameRound(tileArrangement: fallbackTiles, matchablePairCount: calculateMatchablePairs(tiles: fallbackTiles))
    }

    func validatePairSum(_ firstTile: MahjongTile, _ secondTile: MahjongTile) -> Bool {
        firstTile.numericValue + secondTile.numericValue == 10
    }

    func calculateMatchablePairs(tiles: [MahjongTile]) -> Int {
        var tilesByValue = [Int: Int]()

        for tile in tiles {
            tilesByValue[tile.numericValue, default: 0] += 1
        }

        var totalPairs = 0

        for number in 1...4 {
            let oppositeNumber = 10 - number
            let countOfNumber = tilesByValue[number] ?? 0
            let countOfOpposite = tilesByValue[oppositeNumber] ?? 0
            totalPairs += min(countOfNumber, countOfOpposite)
        }

        let countOfFives = tilesByValue[5] ?? 0
        totalPairs += countOfFives / 2

        return totalPairs
    }

    private func createFullDeck() -> [MahjongTile] {
        var completeDeck: [MahjongTile] = []

        for suitCase in MahjongSuit.allCases {
            for number in 1...9 {
                completeDeck.append(MahjongTile(suitType: suitCase, number: number))
            }
        }

        return completeDeck
    }
}
