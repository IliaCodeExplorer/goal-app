import Foundation
import SwiftUI

// MARK: - Character Customization
struct CharacterAppearance: Codable {
    var skinTone: Int = 0
    var outfit: String = "default"
    var accessories: [String] = []
    
    var unlockedOutfits: [String] = ["default"]
    var unlockedAccessories: [String] = []
}

// Предметы одежды и аксессуары (разблокируются за достижения или покупаются)
struct CharacterItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: ItemType
    let icon: String
    let unlockRequirement: UnlockRequirement
    var isUnlocked: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        type: ItemType,
        icon: String,
        unlockRequirement: UnlockRequirement,
        isUnlocked: Bool = false
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.icon = icon
        self.unlockRequirement = unlockRequirement
        self.isUnlocked = isUnlocked
    }
}

enum ItemType: String, Codable {
    case outfit = "Одежда"
    case accessory = "Аксессуар"
    case effect = "Эффект"
}

enum UnlockRequirement: Codable, Equatable {
    case level(Int)
    case achievement(String)
    case stat(String, Int)
    case coins(Int)
    
    var description: String {
        switch self {
        case .level(let lvl):
            return "Уровень \(lvl)"
        case .achievement(let name):
            return "Достижение: \(name)"
        case .stat(let category, let value):
            return "\(category): \(value)"
        case .coins(let amount):
            return "\(amount) монет"
        }
    }
}

// Дефолтные предметы
class CharacterItemsManager {
    static let shared = CharacterItemsManager()
    
    let items: [CharacterItem] = [
        // Одежда
        CharacterItem(name: "Спортивный костюм", type: .outfit, icon: "figure.run", unlockRequirement: .stat("physical", 50), isUnlocked: false),
        CharacterItem(name: "Деловой костюм", type: .outfit, icon: "briefcase.fill", unlockRequirement: .stat("career", 50), isUnlocked: false),
        CharacterItem(name: "Повседневная одежда", type: .outfit, icon: "tshirt.fill", unlockRequirement: .level(5), isUnlocked: false),
        CharacterItem(name: "Элитный костюм", type: .outfit, icon: "crown.fill", unlockRequirement: .level(20), isUnlocked: false),
        
        // Аксессуары
        CharacterItem(name: "Очки интеллектуала", type: .accessory, icon: "eyeglasses", unlockRequirement: .stat("mental", 60), isUnlocked: false),
        CharacterItem(name: "Наушники", type: .accessory, icon: "headphones", unlockRequirement: .coins(500), isUnlocked: false),
        CharacterItem(name: "Часы", type: .accessory, icon: "clock.fill", unlockRequirement: .stat("discipline", 70), isUnlocked: false),
        CharacterItem(name: "Корона чемпиона", type: .accessory, icon: "crown.fill", unlockRequirement: .achievement("Легенда"), isUnlocked: false),
        
        // Эффекты
        CharacterItem(name: "Аура огня", type: .effect, icon: "flame.fill", unlockRequirement: .stat("physical", 80), isUnlocked: false),
        CharacterItem(name: "Аура мудрости", type: .effect, icon: "sparkles", unlockRequirement: .stat("mental", 80), isUnlocked: false),
    ]
}
