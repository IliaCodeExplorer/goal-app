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
    func checkAndResetRepeatingGoals() {
        let calendar = Calendar.current
        let now = Date()
        
        for i in 0..<goals.count {
            var goal = goals[i]
            
            guard goal.isRepeating && goal.isCompleted else { continue }
            
            let shouldReset: Bool
            
            switch goal.frequency {
            case .daily:
                shouldReset = !calendar.isDateInToday(goal.lastUpdated)
            case .weekly:
                let weeksDiff = calendar.dateComponents([.weekOfYear], from: goal.lastUpdated, to: now).weekOfYear ?? 0
                shouldReset = weeksDiff >= 1
            case .monthly:
                let monthsDiff = calendar.dateComponents([.month], from: goal.lastUpdated, to: now).month ?? 0
                shouldReset = monthsDiff >= 1
            case .yearly:
                let yearsDiff = calendar.dateComponents([.year], from: goal.lastUpdated, to: now).year ?? 0
                shouldReset = yearsDiff >= 1
            }
            
            if shouldReset {
                goal.currentValue = 0
                goal.lastUpdated = now
                goals[i] = goal
            }
        }
        
        saveGoals()
    }
}
