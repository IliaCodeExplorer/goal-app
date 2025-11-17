//
//  Reward.swift
//  GoalTracker
//
//  Created by Ilyas on 11/16/25.
//

import Foundation

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

// MARK: - Reward Category
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

// MARK: - Reward Status
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
