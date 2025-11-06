import Foundation
import SwiftUI
import Combine

class GoalManager: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var achievements: [Achievement] = []
    @Published var showAchievementNotification = false
    @Published var latestAchievement: Achievement?
    
    private let goalsKey = "saved_goals"
    private let achievementsKey = "saved_achievements"
    
    init() {
        loadGoals()
        loadAchievements()
        checkAndResetRepeatingGoals()
    }
    
    // MARK: - Goal Management
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveGoals()
        checkForAchievements()
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
            checkForAchievements()
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
            
            // Добавить запись в историю если цель завершена
            if updatedGoal.isCompleted && previousValue < updatedGoal.targetValue {
                let record = CompletionRecord(date: Date(), value: updatedGoal.targetValue)
                updatedGoal.completionHistory.append(record)
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
            
            // Добавить запись в историю если цель завершена
            if updatedGoal.isCompleted && previousValue < updatedGoal.targetValue {
                let record = CompletionRecord(date: Date(), value: updatedGoal.targetValue)
                updatedGoal.completionHistory.append(record)
            }
            
            goals[index] = updatedGoal
            saveGoals()
            checkForAchievements()
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
                    rarity: .common
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
                    rarity: .rare
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
                    rarity: .epic
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
                    rarity: .legendary
                )
            )
        }
        
        // Серия 7 дней
        if hasConsecutiveDays(7) && !hasAchievement(titled: "Недельная Серия") {
            unlockAchievement(
                Achievement(
                    title: "Недельная Серия",
                    description: "7 дней подряд выполнения целей!",
                    icon: "calendar.badge.clock",
                    reward: "📅 Мастер постоянства",
                    rarity: .rare
                )
            )
        }
        
        // Серия 30 дней
        if hasConsecutiveDays(30) && !hasAchievement(titled: "Месячный Марафон") {
            unlockAchievement(
                Achievement(
                    title: "Месячный Марафон",
                    description: "30 дней подряд выполнения целей!",
                    icon: "flame.circle.fill",
                    reward: "🏆 Титан дисциплины",
                    rarity: .epic
                )
            )
        }
        
        // Перфекционист - 100% выполнение всех активных целей
        if !activeGoals.isEmpty && activeGoals.allSatisfy({ $0.isCompleted }) && !hasAchievement(titled: "Перфекционист") {
            unlockAchievement(
                Achievement(
                    title: "Перфекционист",
                    description: "Все активные цели выполнены!",
                    icon: "checkmark.seal.fill",
                    reward: "💎 Безупречное исполнение",
                    rarity: .epic
                )
            )
        }
        
        // Ранняя пташка - завершение до 8 утра
        let calendar = Calendar.current
        if let lastCompletion = goals.flatMap({ $0.completionHistory }).last {
            let hour = calendar.component(.hour, from: lastCompletion.date)
            if hour < 8 && !hasAchievement(titled: "Ранняя Пташка") {
                unlockAchievement(
                    Achievement(
                        title: "Ранняя Пташка",
                        description: "Выполнение целей до 8 утра!",
                        icon: "sunrise.fill",
                        reward: "🌅 Утренняя энергия",
                        rarity: .rare
                    )
                )
            }
        }
    }
    
    private func hasConsecutiveDays(_ days: Int) -> Bool {
        let calendar = Calendar.current
        let completionDates = goals.flatMap { $0.completionHistory.map { $0.date } }
        guard !completionDates.isEmpty else { return false }
        
        let sortedDates = completionDates.sorted(by: >)
        var consecutiveDays = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        for _ in 0..<days {
            if sortedDates.contains(where: { calendar.isDate($0, inSameDayAs: currentDate) }) {
                consecutiveDays += 1
            } else {
                return false
            }
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        return consecutiveDays >= days
    }
    
    private func hasAchievement(titled title: String) -> Bool {
        achievements.contains { $0.title == title }
    }
    
    private func unlockAchievement(_ achievement: Achievement) {
        achievements.append(achievement)
        latestAchievement = achievement
        showAchievementNotification = true
        saveAchievements()
        
        // Скрыть уведомление через 5 секунд
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
