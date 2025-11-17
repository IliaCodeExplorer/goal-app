//
//  Achievment.swift
//  GoalTracker
//
//  Created by Ilyas on 11/16/25.
//

import Foundation

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let dateEarned: Date
    let reward: String
    let rarity: AchievementRarity
    let coinsEarned: Int
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        icon: String,
        dateEarned: Date = Date(),
        reward: String,
        rarity: AchievementRarity = .common,
        coinsEarned: Int = 100
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.dateEarned = dateEarned
        self.reward = reward
        self.rarity = rarity
        self.coinsEarned = coinsEarned
    }
}

// MARK: - Achievement Rarity
enum AchievementRarity: String, Codable, CaseIterable {
    case common = "Common"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    var color: String {
        switch self {
        case .common: return "gray"
        case .rare: return "blue"
        case .epic: return "purple"
        case .legendary: return "orange"
        }
    }
    
    var coinReward: Int {
        switch self {
        case .common: return 100
        case .rare: return 250
        case .epic: return 500
        case .legendary: return 1000
        }
    }
}
