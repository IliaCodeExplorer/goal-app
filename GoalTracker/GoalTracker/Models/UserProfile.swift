//
//  UserProfile.swift
//  GoalTracker
//
//  Created by Ilyas on 11/16/25.
//

import Foundation
import SwiftUI

// MARK: - User Profile
struct UserProfile: Codable {
    var coins: Int
    var level: Int
    var xp: Int
    var streak: Int
    var longestStreak: Int
    var lastActivityDate: Date
    var totalGoalsCompleted: Int
    var characterStats: CharacterStats
    
    init(
        coins: Int = 0,
        level: Int = 1,
        xp: Int = 0,
        streak: Int = 0,
        longestStreak: Int = 0,
        lastActivityDate: Date = Date(),
        totalGoalsCompleted: Int = 0,
        characterStats: CharacterStats = CharacterStats()
    ) {
        self.coins = coins
        self.level = level
        self.xp = xp
        self.streak = streak
        self.longestStreak = longestStreak
        self.lastActivityDate = lastActivityDate
        self.totalGoalsCompleted = totalGoalsCompleted
        self.characterStats = characterStats
    }
    
    var xpToNextLevel: Int {
        level * 100
    }
    
    var levelProgress: Double {
        Double(xp) / Double(xpToNextLevel)
    }
}

// MARK: - Character Stats
struct CharacterStats: Codable {
    var physical: Int = 0
    var mental: Int = 0
    var health: Int = 0
    var career: Int = 0
    var social: Int = 0
    var discipline: Int = 0
    
    var overall: Int {
        (physical + mental + health + career + social + discipline) / 6
    }
    
    var bodyType: BodyType {
        let avgPhysicalHealth = (physical + health) / 2
        if avgPhysicalHealth < 30 { return .overweight }
        if avgPhysicalHealth < 60 { return .average }
        if avgPhysicalHealth < 85 { return .fit }
        return .athletic
    }
    
    mutating func updateStat(for category: StatCategory, change: Int) {
        switch category {
        case .physical: physical = max(0, min(100, physical + change))
        case .mental: mental = max(0, min(100, mental + change))
        case .health: health = max(0, min(100, health + change))
        case .career: career = max(0, min(100, career + change))
        case .social: social = max(0, min(100, social + change))
        case .discipline: discipline = max(0, min(100, discipline + change))
        }
    }
    
    func statValue(for category: StatCategory) -> Int {
        switch category {
        case .physical: return physical
        case .mental: return mental
        case .health: return health
        case .career: return career
        case .social: return social
        case .discipline: return discipline
        }
    }
}

// MARK: - Body Type
enum BodyType: String, Codable {
    case overweight = "Начинающий"
    case average = "Обычный"
    case fit = "Подтянутый"
    case athletic = "Атлет"
    
    var description: String {
        switch self {
        case .overweight: return "Только начинаешь путь"
        case .average: return "На правильном пути"
        case .fit: return "В отличной форме"
        case .athletic: return "Чемпион!"
        }
    }
    
    var emoji: String {
        switch self {
        case .overweight: return "🌱"
        case .average: return "💪"
        case .fit: return "🏋️"
        case .athletic: return "🏆"
        }
    }
}

// MARK: - Stat Category
enum StatCategory: String, CaseIterable, Codable {
    case physical = "Физическая форма"
    case mental = "Интеллект"
    case health = "Здоровье"
    case career = "Карьера"
    case social = "Социальная жизнь"
    case discipline = "Дисциплина"
    
    var icon: String {
        switch self {
        case .physical: return "figure.run"
        case .mental: return "brain.head.profile"
        case .health: return "heart.fill"
        case .career: return "briefcase.fill"
        case .social: return "person.2.fill"
        case .discipline: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .physical: return .red
        case .mental: return .blue
        case .health: return .green
        case .career: return .orange
        case .social: return .pink
        case .discipline: return .purple
        }
    }
    
    static func fromGoalCategory(_ category: GoalCategory) -> StatCategory {
        switch category {
        case .fitness: return .physical
        case .learning: return .mental
        case .health: return .health
        case .business: return .career
        case .family: return .social
        case .achiever: return .discipline
        case .muslim: return .discipline
        }
    }
}
