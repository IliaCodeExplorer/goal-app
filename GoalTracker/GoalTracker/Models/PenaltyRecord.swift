//
//  PenaltyRecord.swift
//  GoalTracker
//
//  Created by Ilyas on 11/17/25.
//

import Foundation

// MARK: - Penalty Record
struct PenaltyRecord: Identifiable, Codable {
    let id: UUID
    let goalId: UUID
    let goalTitle: String
    let date: Date
    let coinsPenalty: Int
    let statsPenalty: Int
    let reason: PenaltyReason
    
    init(
        id: UUID = UUID(),
        goalId: UUID,
        goalTitle: String,
        date: Date = Date(),
        coinsPenalty: Int,
        statsPenalty: Int,
        reason: PenaltyReason
    ) {
        self.id = id
        self.goalId = goalId
        self.goalTitle = goalTitle
        self.date = date
        self.coinsPenalty = coinsPenalty
        self.statsPenalty = statsPenalty
        self.reason = reason
    }
}

// MARK: - Penalty Reason
enum PenaltyReason: String, Codable {
    case notTouched = "Не тронута"
    case incomplete = "Не завершена"
    case markedFailed = "Отмечена как провал"
    
    var icon: String {
        switch self {
        case .notTouched: return "hand.raised.slash"
        case .incomplete: return "xmark.circle"
        case .markedFailed: return "exclamationmark.triangle"
        }
    }
    
    var description: String {
        switch self {
        case .notTouched: return "Цель не была тронута вчера"
        case .incomplete: return "Цель не завершена в срок"
        case .markedFailed: return "Отмечена как провал"
        }
    }
}

// MARK: - Daily Summary
struct DailySummary: Codable {
    let date: Date
    var completedGoals: Int = 0
    var failedGoals: Int = 0
    var coinsEarned: Int = 0
    var coinsLost: Int = 0
    var streakBroken: Bool = false
    var penalties: [PenaltyRecord] = []
    
    var netCoins: Int {
        coinsEarned - coinsLost
    }
}
