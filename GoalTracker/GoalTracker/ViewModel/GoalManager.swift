import Foundation
import SwiftUI
import UIKit
import Combine

// v2.5.3 FINAL - GoalManager БЕЗ вложенного struct Reward

class GoalManager: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var achievements: [Achievement] = []
    @Published var rewards: [Reward] = []  // ← Использует глобальный Reward из Models.swift
    @Published var userProfile: UserProfile = UserProfile()
    @Published var showAchievementNotification = false
    @Published var latestAchievement: Achievement?
    @Published var showLevelUpNotification = false
    @Published var showCoinAnimation = false
    @Published var coinsEarned: Int = 0
    
    private let goalsKey = "saved_goals"
    private let achievementsKey = "saved_achievements"
    private let rewardsKey = "saved_rewards"
    private let profileKey = "saved_profile"
    
    init() {
        loadGoals()
        loadAchievements()
        loadRewards()
        loadProfile()
        checkAndResetRepeatingGoals()
        updateStreak()
    }
    
    // MARK: - Profile Management
    func addCoins(_ amount: Int) {
        userProfile.coins += amount
        coinsEarned = amount
        showCoinAnimation = true
        saveProfile()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showCoinAnimation = false
        }
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        guard userProfile.coins >= amount else { return false }
        userProfile.coins -= amount
        saveProfile()
        return true
    }
    
    func addXP(_ amount: Int) {
        let oldLevel = userProfile.level
        userProfile.xp += amount
        
        while userProfile.xp >= userProfile.xpToNextLevel {
            userProfile.xp -= userProfile.xpToNextLevel
            userProfile.level += 1
        }
        
        if userProfile.level > oldLevel {
            showLevelUpNotification = true
            addCoins(userProfile.level * 50)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showLevelUpNotification = false
            }
        }
        
        saveProfile()
    }
    
    func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastActivity = calendar.startOfDay(for: userProfile.lastActivityDate)
        
        let daysDiff = calendar.dateComponents([.day], from: lastActivity, to: today).day ?? 0
        
        if daysDiff == 0 {
            return
        } else if daysDiff == 1 {
            userProfile.streak += 1
            if userProfile.streak > userProfile.longestStreak {
                userProfile.longestStreak = userProfile.streak
            }
        } else if daysDiff > 1 {
            userProfile.streak = 0
        }
        
        userProfile.lastActivityDate = Date()
        saveProfile()
        
        if userProfile.streak == 7 {
            addCoins(50)
        } else if userProfile.streak == 30 {
            addCoins(200)
        } else if userProfile.streak % 10 == 0 && userProfile.streak > 0 {
            addCoins(userProfile.streak * 5)
        }
    }
    
    // MARK: - Goal Management
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
            
            let wasCompleted = previousValue >= updatedGoal.targetValue
            let isNowCompleted = updatedGoal.currentValue >= updatedGoal.targetValue
            
            if isNowCompleted && !wasCompleted {
                let coins = updatedGoal.coinReward
                let xp = updatedGoal.coinReward * 2
                let record = CompletionRecord(date: Date(), value: updatedGoal.targetValue, coinsEarned: coins)
                updatedGoal.completionHistory.append(record)
                
                addCoins(coins)
                addXP(xp)
                userProfile.totalGoalsCompleted += 1
                updateStreak()
                updateCharacterStats(for: updatedGoal)
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
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
            
            if updatedGoal.trackingType == .habit {
                let coins = updatedGoal.difficulty == .easy ? 5 : 10
                addCoins(coins)
                addXP(coins)
                updateStreak()
                updateCharacterStats(for: updatedGoal, isHabit: true)
            }
            
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
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            goals[index] = updatedGoal
            saveGoals()
        }
    }
    
    // MARK: - Character Stats Update
    private func updateCharacterStats(for goal: Goal, isHabit: Bool = false) {
        let baseGain: Int
        if isHabit {
            baseGain = 1
        } else {
            switch goal.difficulty {
            case .easy: baseGain = 1
            case .medium: baseGain = 2
            case .hard: baseGain = 3
            case .epic: baseGain = 5
            }
        }
        
        let streakBonus: Int
        if userProfile.streak >= 30 {
            streakBonus = 2
        } else if userProfile.streak >= 7 {
            streakBonus = 1
        } else {
            streakBonus = 0
        }
        
        let totalGain = baseGain + streakBonus
        userProfile.characterStats.updateStat(for: .discipline, change: totalGain)
        
        let title = goal.title.lowercased()
        let description = goal.description.lowercased()
        let combinedText = title + " " + description
        
        if combinedText.contains("спорт") || combinedText.contains("тренировка") ||
           combinedText.contains("бег") || combinedText.contains("отжим") ||
           combinedText.contains("зал") || combinedText.contains("йога") ||
           combinedText.contains("растяжка") || combinedText.contains("шаги") ||
           goal.icon.contains("figure") || goal.icon.contains("dumbbell") {
            userProfile.characterStats.updateStat(for: .physical, change: totalGain)
        }
        
        if combinedText.contains("книга") || combinedText.contains("учить") ||
           combinedText.contains("курс") || combinedText.contains("язык") ||
           combinedText.contains("обучение") || combinedText.contains("читать") ||
           combinedText.contains("код") || combinedText.contains("документация") ||
           goal.icon.contains("book") || goal.icon.contains("graduationcap") {
            userProfile.characterStats.updateStat(for: .mental, change: totalGain)
        }
        
        if combinedText.contains("вода") || combinedText.contains("сон") ||
           combinedText.contains("здоров") || combinedText.contains("витамин") ||
           combinedText.contains("питание") || combinedText.contains("сахар") ||
           goal.icon.contains("heart") || goal.icon.contains("drop") ||
           goal.icon.contains("bed") || goal.icon.contains("leaf") {
            userProfile.characterStats.updateStat(for: .health, change: totalGain)
        }
        
        if combinedText.contains("работа") || combinedText.contains("бизнес") ||
           combinedText.contains("проект") || combinedText.contains("встреч") ||
           combinedText.contains("клиент") || combinedText.contains("финанс") ||
           combinedText.contains("рабоч") || goal.icon.contains("briefcase") ||
           goal.icon.contains("chart") {
            userProfile.characterStats.updateStat(for: .career, change: totalGain)
        }
        
        if combinedText.contains("семья") || combinedText.contains("друзья") ||
           combinedText.contains("звонок") || combinedText.contains("супруг") ||
           combinedText.contains("дети") || combinedText.contains("родител") ||
           combinedText.contains("свидание") || goal.icon.contains("person") ||
           goal.icon.contains("heart.fill") || goal.icon.contains("house") {
            userProfile.characterStats.updateStat(for: .social, change: totalGain)
        }
        
        saveProfile()
    }
    
    // MARK: - Reward Management
    func purchaseReward(_ reward: Reward) -> Bool {
        guard spendCoins(reward.cost) else { return false }
        
        if let index = rewards.firstIndex(where: { $0.id == reward.id }) {
            var updatedReward = rewards[index]
            updatedReward.isPurchased = true
            updatedReward.purchaseDate = Date()
            rewards[index] = updatedReward
        }
        
        saveRewards()
        return true
    }
    
    func addCustomReward(_ reward: Reward) {
        rewards.append(reward)
        saveRewards()
    }
    
    func deleteReward(_ reward: Reward) {
        rewards.removeAll { $0.id == reward.id }
        saveRewards()
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
    
    // MARK: - Persistence
    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: goalsKey)
        }
    }
    
    private func loadGoals() {
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let decoded = try? JSONDecoder().decode([Goal].self, from: data) {
            goals = decoded
        }
    }
    
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
    }
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        }
    }
    
    private func saveRewards() {
        if let encoded = try? JSONEncoder().encode(rewards) {
            UserDefaults.standard.set(encoded, forKey: rewardsKey)
        }
    }
    
    private func loadRewards() {
        if let data = UserDefaults.standard.data(forKey: rewardsKey),
           let decoded = try? JSONDecoder().decode([Reward].self, from: data) {
            rewards = decoded
        } else {
            rewards = RewardsManager.shared.defaultVirtualRewards + RewardsManager.shared.defaultRealRewards
            saveRewards()
        }
    }
    
    func saveProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
    }
    
    private func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = decoded
        }
    }
    
    // MARK: - Achievements System
    private func checkForAchievements() {
        let completedGoals = goals.filter { $0.isCompleted }
        
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
    
    private func hasAchievement(titled title: String) -> Bool {
        achievements.contains { $0.title == title }
    }
    
    private func unlockAchievement(_ achievement: Achievement) {
        achievements.append(achievement)
        latestAchievement = achievement
        showAchievementNotification = true
        addCoins(achievement.coinsEarned)
        saveAchievements()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.showAchievementNotification = false
        }
    }
    
    // MARK: - Statistics
    var totalGoals: Int {
        goals.count
    }
    
    var completedGoals: Int {
        goals.filter { $0.isCompleted }.count
    }
    
    var activeGoals: [Goal] {
        goals.filter { $0.isActive && !$0.isCompleted }
    }
    
    var completedGoalsList: [Goal] {
        goals.filter { $0.isCompleted }
    }
    
    var todayGoals: [Goal] {
        goals.filter { $0.frequency == .daily && !$0.isCompleted }
    }
    
    var totalCompletions: Int {
        goals.flatMap { $0.completionHistory }.count
    }
    
    func completionsInLast7Days() -> [Date: Int] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -6, to: endDate) ?? endDate
        
        var completionsByDay: [Date: Int] = [:]
        
        for day in 0...6 {
            if let date = calendar.date(byAdding: .day, value: -day, to: endDate) {
                let startOfDay = calendar.startOfDay(for: date)
                completionsByDay[startOfDay] = 0
            }
        }
        
        let allCompletions = goals.flatMap { $0.completionHistory }
        
        for completion in allCompletions {
            if completion.date >= startDate && completion.date <= endDate {
                let startOfDay = calendar.startOfDay(for: completion.date)
                completionsByDay[startOfDay, default: 0] += 1
            }
        }
        
        return completionsByDay
    }
}
