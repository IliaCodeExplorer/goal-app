//
//  Goals.swift
//  GoalTracker
//
//  Created by Ilyas on 11/16/25.
//

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
        difficulty.coinMultiplier
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
        let wasTracked: Bool  // ← ДОБАВЬ
        let isFailed: Bool    // ← ДОБАВЬ
        
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

// MARK: - Goal Weekly Stats Extension
extension Goal {
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
            let wasTracked: Bool
            
            if trackingType == .numeric {
                // Для numeric: берем последнее значение дня
                if let lastRecord = dayRecords.last {
                    dayValue = lastRecord.value
                    wasTracked = true
                } else {
                    dayValue = 0
                    wasTracked = false
                }
                percentage = targetValue > 0 ? (dayValue / targetValue) * 100 : 0
            } else {
                // Для binary: была ли запись в этот день
                dayValue = dayRecords.isEmpty ? 0 : 1
                percentage = dayValue * 100
                wasTracked = !dayRecords.isEmpty
            }
            
            // Проверяем: день в прошлом и цель не выполнена = провал
            let isPastDay = date < today
            let isFailed = isPastDay && !wasTracked && dayValue < targetValue
            
            dailyValues.append(WeeklyStats.DayValue(
                date: date,
                value: dayValue,
                target: targetValue,
                percentage: min(percentage, 100),
                wasTracked: wasTracked,
                isFailed: isFailed
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
