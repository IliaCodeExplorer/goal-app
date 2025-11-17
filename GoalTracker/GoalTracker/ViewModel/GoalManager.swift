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
    
    // MARK: - Manual Recovery
    func manualRecovery() {
        print("🔍 Попытка восстановления...")
        print("📊 Текущее состояние:")
        print("   Goals: \(goals.count)")
        print("   Coins: \(userProfile.coins)")
        print("   Streak: \(userProfile.streak)")
        print("   Total Completed: \(userProfile.totalGoalsCompleted)")
        
        // Проверяем все возможные ключи
        let possibleKeys = ["saved_goals", "goals_backup", "goals_backup_auto"]
        
        for key in possibleKeys {
            if let data = UserDefaults.standard.data(forKey: key),
               let recovered = try? JSONDecoder().decode([Goal].self, from: data) {
                print("✅ Найдено \(recovered.count) целей в '\(key)'")
                
                if recovered.count > goals.count {
                    goals = recovered
                    saveGoals()
                    print("🎉 Восстановлено!")
                    return
                }
            }
        }
        
        print("❌ Не удалось найти бэкап")
    }
    
    private let goalsKey = "saved_goals"
    private let achievementsKey = "saved_achievements"
    private let rewardsKey = "saved_rewards"
    private let profileKey = "saved_profile"
    
    init() {
        loadGoals()
        loadAchievements()
        loadRewards()
        migrateRewardsIfNeeded()
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
            
            updatedGoal.currentValue = value
            updatedGoal.lastUpdated = Date()
            
            // НОВОЕ: Добавляем запись в историю для ВСЕХ типов целей
            if value >= 0 {
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                
                // Удаляем старую запись за сегодня если есть
                updatedGoal.completionHistory.removeAll {
                    calendar.isDate($0.date, inSameDayAs: today)
                }
                
                // Добавляем новую
                let record = CompletionRecord(
                    date: Date(),
                    value: value,
                    coinsEarned: 0
                )
                updatedGoal.completionHistory.append(record)
            }
            
            // Награды только если цель завершена впервые
            if updatedGoal.isCompleted && previousValue < updatedGoal.targetValue && value >= 0 {
                let coins = updatedGoal.coinReward
                let xp = updatedGoal.coinReward * 2
                
                // Обновляем последнюю запись с наградой
                if var lastRecord = updatedGoal.completionHistory.last {
                    updatedGoal.completionHistory.removeLast()
                    lastRecord = CompletionRecord(
                        id: lastRecord.id,
                        date: lastRecord.date,
                        value: lastRecord.value,
                        coinsEarned: coins
                    )
                    updatedGoal.completionHistory.append(lastRecord)
                }
                
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
    
    func incrementGoalProgress(goalId: UUID, by value: Double = 1) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            let newValue = goals[index].currentValue + value
            updateGoalProgress(goalId: goalId, value: newValue)
        }
    }

    func decrementGoalProgress(goalId: UUID, by value: Double = 1) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            let newValue = max(0, goals[index].currentValue - value)
            updateGoalProgress(goalId: goalId, value: newValue)
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
    // MARK: - Reward Management

    func purchaseReward(_ reward: Reward) -> Bool {
        guard userProfile.coins >= reward.cost else { return false }
        
        // Списываем монеты
        userProfile.coins -= reward.cost
        
        // Добавляем запись в историю покупок
        if let index = rewards.firstIndex(where: { $0.id == reward.id }) {
            let record = PurchaseRecord(cost: reward.cost)
            rewards[index].purchaseHistory.append(record)
        }
        
        saveRewards()
        saveProfile()
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        return true
    }

    func redeemPurchase(rewardId: UUID, purchaseId: UUID) -> Bool {
        guard let rewardIndex = rewards.firstIndex(where: { $0.id == rewardId }),
              let purchaseIndex = rewards[rewardIndex].purchaseHistory.firstIndex(where: { $0.id == purchaseId }) else {
            return false
        }
        
        rewards[rewardIndex].purchaseHistory[purchaseIndex].isRedeemed = true
        rewards[rewardIndex].purchaseHistory[purchaseIndex].redeemedDate = Date()
        
        saveRewards()
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        return true
    }

    func redeemOldestPurchase(rewardId: UUID) -> Bool {
        guard let rewardIndex = rewards.firstIndex(where: { $0.id == rewardId }),
              let purchaseIndex = rewards[rewardIndex].purchaseHistory.firstIndex(where: { !$0.isRedeemed }) else {
            return false
        }
        
        rewards[rewardIndex].purchaseHistory[purchaseIndex].isRedeemed = true
        rewards[rewardIndex].purchaseHistory[purchaseIndex].redeemedDate = Date()
        
        saveRewards()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        return true
    }

    func addCustomReward(_ reward: Reward) {
        var newReward = reward
        newReward.isCustom = true
        rewards.append(newReward)
        saveRewards()
    }

    func deleteReward(_ reward: Reward) {
        rewards.removeAll { $0.id == reward.id }
        saveRewards()
    }

    // Статистика наград
    var totalRewardsRedeemed: Int {
        rewards.flatMap { $0.purchaseHistory }.filter { $0.isRedeemed }.count
    }

    var totalCoinsSpentOnRewards: Int {
        rewards.flatMap { $0.purchaseHistory }.reduce(0) { $0 + $1.cost }
    }

    var pendingRedemptions: [Reward] {
        rewards.filter { $0.hasUnredeemedPurchases }
    }
    
    // MARK: - Repeating Goals
    // MARK: - Repeating Goals Auto-Reset
    // MARK: - Repeating Goals Auto-Reset
    func checkAndResetRepeatingGoals() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let now = Date()
        
        var hasChanges = false
        
        print("🔄 Checking repeating goals...")
        print("📅 Current date: \(now)")
        print("🌍 TimeZone: \(TimeZone.current.identifier)")
        
        for i in 0..<goals.count {
            var goal = goals[i]
            
            // ИЗМЕНЕНИЕ: Сбрасываем ВСЕ repeating цели, не только completed
            guard goal.isRepeating else { continue }
            
            let shouldReset: Bool
            let lastUpdate = goal.lastUpdated
            
            print("   Checking: \(goal.title)")
            print("   Last updated: \(lastUpdate)")
            print("   Current value: \(goal.currentValue)")
            print("   Frequency: \(goal.frequency)")
            
            switch goal.frequency {
            case .daily:
                shouldReset = !calendar.isDate(lastUpdate, inSameDayAs: now)
                
            case .weekly:
                let lastWeek = calendar.component(.weekOfYear, from: lastUpdate)
                let currentWeek = calendar.component(.weekOfYear, from: now)
                let lastYear = calendar.component(.year, from: lastUpdate)
                let currentYear = calendar.component(.year, from: now)
                shouldReset = (currentWeek != lastWeek) || (currentYear != lastYear)
                
            case .monthly:
                let lastMonth = calendar.component(.month, from: lastUpdate)
                let currentMonth = calendar.component(.month, from: now)
                let lastYear = calendar.component(.year, from: lastUpdate)
                let currentYear = calendar.component(.year, from: now)
                shouldReset = (currentMonth != lastMonth) || (currentYear != lastYear)
                
            case .yearly:
                let lastYear = calendar.component(.year, from: lastUpdate)
                let currentYear = calendar.component(.year, from: now)
                shouldReset = currentYear != lastYear
            }
            
            if shouldReset {
                print("   ✅ Resetting goal: \(goal.title)")
                print("   Old value: \(goal.currentValue) → New value: 0")
                
                // КРИТИЧНО: Сбрасываем currentValue в 0
                goal.currentValue = 0
                goal.lastUpdated = now
                goals[i] = goal
                hasChanges = true
            } else {
                print("   ⏭️  No reset needed")
            }
        }
        
        if hasChanges {
            saveGoals()
            print("💾 Saved reset goals")
            
            // НОВОЕ: Принудительное обновление UI
            objectWillChange.send()
        } else {
            print("✓ No goals needed reset")
        }
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
            // Первый запуск - загружаем дефолтные
            rewards = RewardsManager.shared.defaultRewards
            saveRewards()
        }
    }
    // Добавь эту функцию после loadRewards():
    private func migrateRewardsIfNeeded() {
        // Если награды пустые или старого формата - перезагрузить
        if rewards.isEmpty {
            rewards = RewardsManager.shared.defaultRewards
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
        
        // Первая победа
        if completedGoals.count == 1 && !hasAchievement(titled: "Первая Победа") {
            unlockAchievement(
                Achievement(
                    title: "Первая Победа",
                    description: "Завершена первая цель!",
                    icon: "star.fill",
                    reward: "🌟 Начало пути",
                    rarity: AchievementRarity.common,
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
                    rarity: AchievementRarity.rare,
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
                    rarity: AchievementRarity.epic,
                    coinsEarned: 500
                )
            )
        }
        
        // 25 целей - Легендарное
        if completedGoals.count >= 25 && !hasAchievement(titled: "Легенда") {
            unlockAchievement(
                Achievement(
                    title: "Легенда",
                    description: "Завершено 25 целей!",
                    icon: "sparkles",
                    reward: "✨ Легендарный статус",
                    rarity: AchievementRarity.legendary,
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
                    rarity: AchievementRarity.rare,
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
                    rarity: AchievementRarity.epic,
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
    // MARK: - Smart Sorting
    var dailyGoals: [Goal] {
        goals
            .filter { $0.isActive && !$0.isCompleted && $0.frequency == .daily }
            .sorted { $0.progressPercentage < $1.progressPercentage }
    }

    var weeklyGoals: [Goal] {
        goals
            .filter { $0.isActive && !$0.isCompleted && $0.frequency == .weekly }
            .sorted { $0.progressPercentage < $1.progressPercentage }
    }

    var monthlyGoals: [Goal] {
        goals
            .filter { $0.isActive && !$0.isCompleted && $0.frequency == .monthly }
            .sorted { $0.progressPercentage < $1.progressPercentage }
    }

    var yearlyGoals: [Goal] {
        goals
            .filter { $0.isActive && !$0.isCompleted && $0.frequency == .yearly }
            .sorted { $0.progressPercentage < $1.progressPercentage }
    }
}
