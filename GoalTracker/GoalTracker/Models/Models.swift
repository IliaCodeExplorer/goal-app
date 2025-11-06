import Foundation

// MARK: - Goal Model
struct Goal: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var frequency: Frequency
    var trackingType: TrackingType
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
}

// MARK: - Completion Record
struct CompletionRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let value: Double
    
    init(id: UUID = UUID(), date: Date = Date(), value: Double) {
        self.id = id
        self.date = date
        self.value = value
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
    
    var icon: String {
        switch self {
        case .binary: return "checkmark.circle"
        case .numeric: return "number.circle"
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
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        icon: String,
        dateEarned: Date = Date(),
        reward: String,
        rarity: AchievementRarity = .common
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.dateEarned = dateEarned
        self.reward = reward
        self.rarity = rarity
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
}
