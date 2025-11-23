//
//  GoalManager+Goals.swift
//  GoalTracker
//
//  Created by Ilyas on 11/17/25.
//

import Foundation
import SwiftUI

// MARK: - Goal Management
extension GoalManager {
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveGoals()
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
    }
    
    func updateGoalProgress(goalId: UUID, value: Double) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            var updatedGoal = goals[index]
            let previousValue = updatedGoal.currentValue
            updatedGoal.currentValue = max(0, min(value, updatedGoal.targetValue))
            updatedGoal.lastUpdated = Date()
            
            // Добавить запись в историю и награды если цель завершена
            if updatedGoal.isCompleted && previousValue < updatedGoal.targetValue {
                let coins = updatedGoal.coinReward
                let xp = updatedGoal.coinReward * 2
                let record = CompletionRecord(date: Date(), value: updatedGoal.targetValue, coinsEarned: coins)
                updatedGoal.completionHistory.append(record)
                
                addCoins(coins)
                addXP(xp)
                userProfile.totalGoalsCompleted += 1
                updateStreak()
                
                // Прокачать характеристику персонажа
                updateCharacterStats(for: updatedGoal)
            }
            
            goals[index] = updatedGoal
            saveGoals()
            checkForAchievements()
        }
    }
    
    func incrementGoalProgress(goalId: UUID, by value: Double = 1) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            var updatedGoal = goals[index]
            let previousValue = updatedGoal.currentValue
            updatedGoal.currentValue = min(updatedGoal.currentValue + value, updatedGoal.targetValue)
            updatedGoal.lastUpdated = Date()
            
            // Для habit типа награждаем каждый раз
            if updatedGoal.trackingType == .habit {
                let coins = updatedGoal.difficulty == .easy ? 5 : 10
                addCoins(coins)
                addXP(coins)
                updateStreak()
                
                updateCharacterStats(for: updatedGoal, isHabit: true)
            }
            
            // Добавить запись в историю и награды если цель завершена
            if updatedGoal.isCompleted && previousValue < updatedGoal.targetValue {
                let coins = updatedGoal.coinReward
                let xp = updatedGoal.coinReward * 2
                let record = CompletionRecord(date: Date(), value: updatedGoal.targetValue, coinsEarned: coins)
                updatedGoal.completionHistory.append(record)
                
                addCoins(coins)
                addXP(xp)
                userProfile.totalGoalsCompleted += 1
                updateStreak()
                
                updateCharacterStats(for: updatedGoal)
            }
            
            goals[index] = updatedGoal
            saveGoals()
            checkForAchievements()
        }
    }
    
    func decrementGoalProgress(goalId: UUID, by value: Double = 1) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            var updatedGoal = goals[index]
            updatedGoal.currentValue = max(0, updatedGoal.currentValue - value)
            updatedGoal.lastUpdated = Date()
            
            // Штраф за минус
            if updatedGoal.trackingType == .habit {
                let penalty = updatedGoal.difficulty == .easy ? 3 : 5
                userProfile.coins = max(0, userProfile.coins - penalty)
                saveProfile()
            }
            
            goals[index] = updatedGoal
            saveGoals()
        }
    }
    
    // MARK: - Repeating Goals
    // MARK: - Repeating Goals Reset
    func checkAndResetRepeatingGoals() {
        let calendar = Calendar.current
        let now = Date()
        
        print("🔄 Checking repeating goals at \(now)")
        print("📊 Total goals: \(goals.count)")
        
        var resetCount = 0
        
        for i in 0..<goals.count {
            var goal = goals[i]
            
            guard goal.isRepeating else { continue }
            
            let lastUpdate = goal.lastUpdated
            let hoursSinceUpdate = calendar.dateComponents([.hour], from: lastUpdate, to: now).hour ?? 0
            
            print("📋 Goal: \(goal.title)")
            print("   - Frequency: \(goal.frequency.rawValue)")
            print("   - Last updated: \(lastUpdate)")
            print("   - Hours since update: \(hoursSinceUpdate)")
            print("   - Is completed: \(goal.isCompleted)")
            print("   - Current value: \(goal.currentValue)/\(goal.targetValue)")
            
            let shouldReset: Bool
            
            switch goal.frequency {
            case .daily:
                // Проверяем по локальному времени пользователя
                let userCalendar = Calendar.current
                let lastUpdateLocal = lastUpdate
                let nowLocal = now
                
                // Начало сегодняшнего дня в локальном времени
                let startOfToday = userCalendar.startOfDay(for: nowLocal)
                let startOfLastUpdate = userCalendar.startOfDay(for: lastUpdateLocal)
                
                // Если lastUpdate был НЕ сегодня (по локальному времени)
                let isNotToday = startOfLastUpdate < startOfToday
                shouldReset = isNotToday
                
                print("   - Start of today (local): \(startOfToday)")
                print("   - Start of last update: \(startOfLastUpdate)")
                print("   - Is not today: \(isNotToday)")
                
            case .weekly:
                let weeksDiff = calendar.dateComponents([.weekOfYear], from: lastUpdate, to: now).weekOfYear ?? 0
                shouldReset = weeksDiff >= 1
                print("   - Weeks diff: \(weeksDiff)")
                
            case .monthly:
                let monthsDiff = calendar.dateComponents([.month], from: lastUpdate, to: now).month ?? 0
                shouldReset = monthsDiff >= 1
                print("   - Months diff: \(monthsDiff)")
                
            case .yearly:
                let yearsDiff = calendar.dateComponents([.year], from: lastUpdate, to: now).year ?? 0
                shouldReset = yearsDiff >= 1
                print("   - Years diff: \(yearsDiff)")
            }
            
            print("   - Should reset: \(shouldReset)")
            
            if shouldReset {
                print("✅ RESETTING: \(goal.title)")
                goal.currentValue = 0
                goal.lastUpdated = now
                goals[i] = goal
                resetCount += 1
            }
        }
        
        if resetCount > 0 {
            print("🔄 Reset \(resetCount) repeating goals")
            saveGoals()
        } else {
            print("✅ No goals to reset")
        }
    }
    // MARK: - Daily Failure Check & Penalties
    func checkForDailyFailures() {
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now
        let startOfYesterday = calendar.startOfDay(for: yesterday)
        let endOfYesterday = calendar.date(byAdding: .day, value: 1, to: startOfYesterday) ?? now
        
        print("⚠️ Checking for daily failures...")
        print("📅 Yesterday: \(startOfYesterday)")
        
        // Очистить старые штрафы
        userProfile.todayPenalties.removeAll()
        
        var penaltiesApplied = 0
        
        for i in 0..<goals.count {
            var goal = goals[i]
            
            // Только для daily целей
            guard goal.frequency == .daily else { continue }
            
            // Проверяем была ли активность вчера
            let yesterdayRecords = goal.completionHistory.filter { record in
                record.date >= startOfYesterday && record.date < endOfYesterday
            }
            
            // Если вчера не было записей И lastUpdated не вчера = ПРОВАЛ
            let wasUpdatedYesterday = calendar.isDate(goal.lastUpdated, inSameDayAs: startOfYesterday)
            
            if yesterdayRecords.isEmpty && !wasUpdatedYesterday {
                print("❌ FAILURE: \(goal.title) - no activity yesterday")
                
                // Применить штраф
                let penalty = applyFailurePenalty(for: goal)
                userProfile.todayPenalties.append(penalty)
                
                // Записать провал в историю
                let failureRecord = CompletionRecord(
                    date: startOfYesterday,
                    value: 0,
                    coinsEarned: -penalty.coinsPenalty
                )
                goal.completionHistory.append(failureRecord)
                goals[i] = goal
                
                penaltiesApplied += 1
            }
        }
        
        if penaltiesApplied > 0 {
            print("⚠️ Applied \(penaltiesApplied) penalties")
            
            // Показать утренний брифинг
            userProfile.showDailyBriefing = true
            userProfile.lastBriefingDate = now
            
            saveGoals()
            saveProfile()
        } else {
            print("✅ No failures detected")
        }
    }

    private func applyFailurePenalty(for goal: Goal) -> PenaltyRecord {
        // Штраф монетами (половина от награды за цель)
        let coinPenalty = goal.difficulty.coinMultiplier / 2
        userProfile.coins = max(0, userProfile.coins - coinPenalty)
        
        // Штраф характеристикам
        let statPenalty: Int
        switch goal.difficulty {
        case .easy: statPenalty = 1
        case .medium: statPenalty = 2
        case .hard: statPenalty = 3
        case .epic: statPenalty = 5
        }
        
        userProfile.characterStats.updateStat(for: .discipline, change: -statPenalty)
        
        // Сбросить streak
        if userProfile.streak > 0 {
            userProfile.streak = 0
        }
        
        let penalty = PenaltyRecord(
            goalId: goal.id,
            goalTitle: goal.title,
            coinsPenalty: coinPenalty,
            statsPenalty: statPenalty,
            reason: .notTouched
        )
        
        print("💰 Penalty: -\(coinPenalty) coins, -\(statPenalty) discipline")
        
        return penalty
    }
}
