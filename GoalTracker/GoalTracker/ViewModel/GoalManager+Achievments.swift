//
//  GoalManager+Achievments.swift
//  GoalTracker
//
//  Created by Ilyas on 11/17/25.
//

import Foundation

// MARK: - Achievements System
extension GoalManager {
    
    func checkForAchievements() {
        let completedGoals = goals.filter { $0.isCompleted }
        
        // Первая победа
        if completedGoals.count == 1 && !hasAchievement(titled: "Первая Победа") {
            unlockAchievement(
                Achievement(
                    title: "Первая Победа",
                    description: "Завершена первая цель!",
                    icon: "star.fill",
                    reward: "🌟 Начало пути",
                    rarity: .common,
                    coinsEarned: 100
                )
            )
        }
        
        // 5 целей
        if completedGoals.count >= 5 && !hasAchievement(titled: "Разрушитель Целей") {
            unlockAchievement(
                Achievement(
                    title: "Разрушитель Целей",
                    description: "Завершено 5 целей!",
                    icon: "flame.fill",
                    reward: "🔥 Огненная серия",
                    rarity: .rare,
                    coinsEarned: 250
                )
            )
        }
        
        // 10 целей
        if completedGoals.count >= 10 && !hasAchievement(titled: "Неудержимый") {
            unlockAchievement(
                Achievement(
                    title: "Неудержимый",
                    description: "Завершено 10 целей!",
                    icon: "crown.fill",
                    reward: "👑 Корона победителя",
                    rarity: .epic,
                    coinsEarned: 500
                )
            )
        }
        
        // 25 целей
        if completedGoals.count >= 25 && !hasAchievement(titled: "Легенда") {
            unlockAchievement(
                Achievement(
                    title: "Легенда",
                    description: "Завершено 25 целей!",
                    icon: "sparkles",
                    reward: "✨ Легендарный статус",
                    rarity: .legendary,
                    coinsEarned: 1000
                )
            )
        }
        
        // Серия 7 дней
        if userProfile.streak >= 7 && !hasAchievement(titled: "Недельная Серия") {
            unlockAchievement(
                Achievement(
                    title: "Недельная Серия",
                    description: "7 дней подряд выполнения целей!",
                    icon: "calendar.badge.clock",
                    reward: "📅 Мастер постоянства",
                    rarity: .rare,
                    coinsEarned: 250
                )
            )
        }
        
        // Серия 30 дней
        if userProfile.streak >= 30 && !hasAchievement(titled: "Месячный Марафон") {
            unlockAchievement(
                Achievement(
                    title: "Месячный Марафон",
                    description: "30 дней подряд выполнения целей!",
                    icon: "flame.circle.fill",
                    reward: "🏆 Титан дисциплины",
                    rarity: .epic,
                    coinsEarned: 500
                )
            )
        }
    }
    
    func hasAchievement(titled title: String) -> Bool {
        achievements.contains { $0.title == title }
    }
    
    func unlockAchievement(_ achievement: Achievement) {
        achievements.append(achievement)
        latestAchievement = achievement
        showAchievementNotification = true
        addCoins(achievement.coinsEarned)
        saveAchievements()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.showAchievementNotification = false
        }
    }
}
