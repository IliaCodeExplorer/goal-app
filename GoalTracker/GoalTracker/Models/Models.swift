import Foundation
import SwiftUI

// MARK: - Goal Model
struct Goal: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var frequency: Frequency
    var trackingType: TrackingType
    var difficulty: Difficulty
    var targetValue: Double
    var currentValue: Double
    var createdDate: Date
    var lastUpdated: Date
    var isActive: Bool
    var icon: String
    var isRepeating: Bool
    var completionHistory: [CompletionRecord]
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        frequency: Frequency,
        trackingType: TrackingType,
        difficulty: Difficulty = .medium,
        targetValue: Double,
        currentValue: Double = 0,
        createdDate: Date = Date(),
        lastUpdated: Date = Date(),
        isActive: Bool = true,
        icon: String = "target",
        isRepeating: Bool = false,
        completionHistory: [CompletionRecord] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.frequency = frequency
        self.trackingType = trackingType
        self.difficulty = difficulty
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.createdDate = createdDate
        self.lastUpdated = lastUpdated
        self.isActive = isActive
        self.icon = icon
        self.isRepeating = isRepeating
        self.completionHistory = completionHistory
    }
    
    var progressPercentage: Double {
        guard targetValue > 0 else { return 0 }
        return min((currentValue / targetValue) * 100, 100)
    }
    
    var isCompleted: Bool {
        currentValue >= targetValue
    }
    
    var coinReward: Int {
        let baseReward = difficulty.coinMultiplier
        return baseReward
    }
    
    // Weekly stats для ВСЕХ типов целей
    var weeklyStats: WeeklyStats? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var dailyValues: [WeeklyStats.DayValue] = []
        var totalValue: Double = 0
        var successCount = 0
        
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            let dayRecords = completionHistory.filter {
                calendar.isDate($0.date, inSameDayAs: date)
            }
            
            let dayValue: Double
            let percentage: Double
            
            if trackingType == .numeric {
                dayValue = dayRecords.last?.value ?? 0
                percentage = targetValue > 0 ? (dayValue / targetValue) * 100 : 0
            } else {
                dayValue = dayRecords.isEmpty ? 0 : 1
                percentage = dayValue * 100
            }
            
            dailyValues.append(WeeklyStats.DayValue(
                date: date,
                value: dayValue,
                target: targetValue,
                percentage: min(percentage, 100)
            ))
            
            totalValue += dayValue
            if percentage >= 100 {
                successCount += 1
            }
        }
        
        let averageValue = totalValue / 7.0
        let averagePercentage: Double
        
        if trackingType == .numeric {
            averagePercentage = targetValue > 0 ? (averageValue / targetValue) * 100 : 0
        } else {
            averagePercentage = Double(successCount) / 7.0 * 100
        }
        
        let successRate = Double(successCount) / 7.0 * 100
        
        let firstHalf = dailyValues.prefix(3).map { $0.percentage }.reduce(0, +) / 3.0
        let secondHalf = dailyValues.suffix(4).map { $0.percentage }.reduce(0, +) / 4.0
        
        let trend: Trend
        if secondHalf > firstHalf + 10 {
            trend = .improving
        } else if secondHalf < firstHalf - 10 {
            trend = .declining
        } else {
            trend = .stable
        }
        
        return WeeklyStats(
            dailyValues: dailyValues,
            averageValue: averageValue,
            averagePercentage: min(averagePercentage, 100),
            totalValue: totalValue,
            totalTarget: targetValue * 7,
            successRate: successRate,
            trend: trend,
            trackingType: trackingType
        )
    }
}

// MARK: - Completion Record
struct CompletionRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let value: Double
    let coinsEarned: Int
    
    init(id: UUID = UUID(), date: Date = Date(), value: Double, coinsEarned: Int = 0) {
        self.id = id
        self.date = date
        self.value = value
        self.coinsEarned = coinsEarned
    }
}

// MARK: - Weekly Stats
struct WeeklyStats {
    let dailyValues: [DayValue]
    let averageValue: Double
    let averagePercentage: Double
    let totalValue: Double
    let totalTarget: Double
    let successRate: Double
    let trend: Trend
    let trackingType: TrackingType
    
    struct DayValue: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
        let target: Double
        let percentage: Double
        
        var dayName: String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateFormat = "EEE"
            let day = formatter.string(from: date)
            return String(day.prefix(2)).capitalized
        }
    }
}

// MARK: - Trend
enum Trend {
    case improving
    case stable
    case declining
    
    var icon: String {
        switch self {
        case .improving: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .declining: return "arrow.down.right"
        }
    }
    
    var color: Color {
        switch self {
        case .improving: return .green
        case .stable: return .orange
        case .declining: return .red
        }
    }
}

// MARK: - Enums
enum Frequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

enum TrackingType: String, Codable, CaseIterable {
    case binary = "Yes/No"
    case numeric = "Number"
    case habit = "Habit"
    
    var icon: String {
        switch self {
        case .binary: return "checkmark.circle"
        case .numeric: return "number.circle"
        case .habit: return "repeat.circle"
        }
    }
    
    var description: String {
        switch self {
        case .binary: return "Завершено или не завершено"
        case .numeric: return "Достичь числового значения"
        case .habit: return "Отмечать каждый раз"
        }
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case epic = "Epic"
    
    var emoji: String {
        switch self {
        case .easy: return "🟢"
        case .medium: return "🟡"
        case .hard: return "🔴"
        case .epic: return "🟣"
        }
    }
    
    var coinMultiplier: Int {
        switch self {
        case .easy: return 10
        case .medium: return 25
        case .hard: return 50
        case .epic: return 100
        }
    }
    
    var color: String {
        switch self {
        case .easy: return "green"
        case .medium: return "yellow"
        case .hard: return "red"
        case .epic: return "purple"
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "Простая цель, легко достижима"
        case .medium: return "Требует усилий и постоянства"
        case .hard: return "Сложная, нужна дисциплина"
        case .epic: return "Эпическая цель, максимальный челлендж"
        }
    }
}

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

// MARK: - Reward Model
// MARK: - Reward Model
struct Reward: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var cost: Int
    var icon: String
    var category: RewardCategory
    var isCustom: Bool
    var purchaseHistory: [PurchaseRecord]
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        cost: Int,
        icon: String,
        category: RewardCategory,
        status: RewardStatus = .available,
        purchaseDate: Date? = nil,
        redeemedDate: Date? = nil,
        isCustom: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.cost = cost
        self.icon = icon
        self.category = category
        self.isCustom = isCustom
        self.purchaseHistory = []
    }
    
    // Удобные проверки
    var totalPurchases: Int {
        purchaseHistory.count
    }
    
    var totalSpent: Int {
        purchaseHistory.reduce(0) { $0 + $1.cost }
    }
    
    var todayPurchases: Int {
        let calendar = Calendar.current
        return purchaseHistory.filter {
            calendar.isDateInToday($0.date)
        }.count
    }
    
    var weekPurchases: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return purchaseHistory.filter {
            $0.date >= weekAgo
        }.count
    }
    
    var pendingRedemptions: Int {
        purchaseHistory.filter { !$0.isRedeemed }.count
    }
    
    var lastPurchaseDate: Date? {
        purchaseHistory.last?.date
    }
    
    var isPurchased: Bool {
        !purchaseHistory.isEmpty
    }
    
    var hasUnredeemedPurchases: Bool {
        purchaseHistory.contains { !$0.isRedeemed }
    }
}

// MARK: - Purchase Record
struct PurchaseRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let cost: Int
    var isRedeemed: Bool
    var redeemedDate: Date?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        cost: Int,
        isRedeemed: Bool = false,
        redeemedDate: Date? = nil
    ) {
        self.id = id
        self.date = date
        self.cost = cost
        self.isRedeemed = isRedeemed
        self.redeemedDate = redeemedDate
    }
}

// MARK: - Reward Status (для обратной совместимости)
enum RewardStatus: String, Codable, CaseIterable {
    case available = "Доступно"
    case purchased = "Куплено"
    case redeemed = "Использовано"
    
    var icon: String {
        switch self {
        case .available: return "cart"
        case .purchased: return "bag.fill"
        case .redeemed: return "checkmark.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .available: return "blue"
        case .purchased: return "orange"
        case .redeemed: return "green"
        }
    }
}
enum RewardCategory: String, Codable, CaseIterable {
    case instant = "Мгновенное"
    case experience = "Впечатления"
    case purchase = "Покупка"
    case bigGoal = "Большая цель"
    
    var icon: String {
        switch self {
        case .instant: return "bolt.fill"
        case .experience: return "star.fill"
        case .purchase: return "bag.fill"
        case .bigGoal: return "trophy.fill"
        }
    }
    
    var description: String {
        switch self {
        case .instant: return "Кофе, сладкое, час отдыха"
        case .experience: return "Кино, ресторан, массаж"
        case .purchase: return "Одежда, техника, аксессуары"
        case .bigGoal: return "Путешествие, крупная покупка"
        }
    }
}

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
    var health: Int
    var maxHealth: Int
    
    init(
        coins: Int = 0,
        level: Int = 1,
        xp: Int = 0,
        streak: Int = 0,
        longestStreak: Int = 0,
        lastActivityDate: Date = Date(),
        totalGoalsCompleted: Int = 0,
        characterStats: CharacterStats = CharacterStats(),
        health: Int = 100,
        maxHealth: Int = 100
    ) {
        self.coins = coins
        self.level = level
        self.xp = xp
        self.streak = streak
        self.longestStreak = longestStreak
        self.lastActivityDate = lastActivityDate
        self.totalGoalsCompleted = totalGoalsCompleted
        self.characterStats = characterStats
        self.health = health
        self.maxHealth = maxHealth
    }
    
    var xpToNextLevel: Int {
        return level * 100
    }
    
    var levelProgress: Double {
        return Double(xp) / Double(xpToNextLevel)
    }
    
    var healthPercentage: Double {
        return Double(health) / Double(maxHealth)
    }
    
    var healthColor: Color {
        if healthPercentage > 0.6 { return .green }
        if healthPercentage > 0.3 { return .orange }
        return .red
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
        let total = physical + mental + health + career + social + discipline
        return total / 6
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
        case .physical:
            physical = max(0, min(100, physical + change))
        case .mental:
            mental = max(0, min(100, mental + change))
        case .health:
            health = max(0, min(100, health + change))
        case .career:
            career = max(0, min(100, career + change))
        case .social:
            social = max(0, min(100, social + change))
        case .discipline:
            discipline = max(0, min(100, discipline + change))
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

// MARK: - BodyType
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

// MARK: - StatCategory
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
