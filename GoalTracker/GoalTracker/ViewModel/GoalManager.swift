import Foundation
import SwiftUI
import Combine

class GoalManager: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var achievements: [Achievement] = []
    @Published var rewards: [Reward] = []
    @Published var userProfile: UserProfile = UserProfile()
    @Published var showAchievementNotification = false
    @Published var latestAchievement: Achievement?
    @Published var showLevelUpNotification = false
    @Published var showCoinAnimation = false
    @Published var coinsEarned: Int = 0
    
    let goalsKey = "saved_goals"
    let achievementsKey = "saved_achievements"
    let rewardsKey = "saved_rewards"
    let profileKey = "saved_profile"
    
    init() {
        loadGoals()
        loadAchievements()
        loadRewards()
        loadProfile()
        checkAndResetRepeatingGoals()
        updateStreak()
    }
    
    // MARK: - Persistence
    func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: goalsKey)
        }
    }
    
    func loadGoals() {
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let decoded = try? JSONDecoder().decode([Goal].self, from: data) {
            goals = decoded
        }
    }
    
    func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
    }
    
    func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        }
    }
    
    func saveRewards() {
        if let encoded = try? JSONEncoder().encode(rewards) {
            UserDefaults.standard.set(encoded, forKey: rewardsKey)
        }
    }
    
    func loadRewards() {
        if let data = UserDefaults.standard.data(forKey: rewardsKey),
           let decoded = try? JSONDecoder().decode([Reward].self, from: data) {
            rewards = decoded
        } else {
            rewards = RewardsManager.shared.defaultRewards
            saveRewards()
        }
    }
    
    func saveProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
    }
    
    func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = decoded
        }
    }
    // MARK: - Statistics (Computed Properties)
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
    
    var dailyGoals: [Goal] {
        goals.filter { $0.frequency == .daily }
    }
    
    var weeklyGoals: [Goal] {
        goals.filter { $0.frequency == .weekly }
    }
    
    var monthlyGoals: [Goal] {
        goals.filter { $0.frequency == .monthly }
    }
    
    var yearlyGoals: [Goal] {
        goals.filter { $0.frequency == .yearly }
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
    
//    func completionsInLast7Days() -> [Date: Int] {
//        let calendar = Calendar.current
//        let endDate = Date()
//        let startDate = calendar.date(byAdding: .day, value: -6, to: endDate) ?? endDate
//        
//        var completionsByDay: [Date: Int] = [:]
//        
//        for day in 0...6 {
//            if let date = calendar.date(byAdding: .day, value: -day, to: endDate) {
//                let startOfDay = calendar.startOfDay(for: date)
//                completionsByDay[startOfDay] = 0
//            }
//        }
//        
//        let allCompletions = goals.flatMap { $0.completionHistory }
//        
//        for completion in allCompletions {
//            if completion.date >= startDate && completion.date <= endDate {
//                let startOfDay = calendar.startOfDay(for: completion.date)
//                completionsByDay[startOfDay, default: 0] += 1
//            }
//        }
//        
//        return completionsByDay
//    }
//}
