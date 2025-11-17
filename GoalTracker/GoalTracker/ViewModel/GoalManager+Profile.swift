//
//  GoalManager+Profile.swift
//  GoalTracker
//
//  Created by Ilyas on 11/17/25.
//

import Foundation
import SwiftUI

// MARK: - Profile & Character Management
extension GoalManager {
    
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
        
        // Награды за streak
        if userProfile.streak == 7 {
            addCoins(50)
        } else if userProfile.streak == 30 {
            addCoins(200)
        } else if userProfile.streak % 10 == 0 && userProfile.streak > 0 {
            addCoins(userProfile.streak * 5)
        }
    }
    
    // MARK: - Character Stats Update
    func updateCharacterStats(for goal: Goal, isHabit: Bool = false) {
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
        
        // Всегда прокачиваем дисциплину
        userProfile.characterStats.updateStat(for: .discipline, change: totalGain)
        
        // Определяем специфичную характеристику
        let title = goal.title.lowercased()
        let description = goal.description.lowercased()
        let combinedText = title + " " + description
        
        // ФИЗИЧЕСКАЯ ФОРМА
        if combinedText.contains("спорт") || combinedText.contains("тренировка") ||
           combinedText.contains("бег") || combinedText.contains("отжим") ||
           combinedText.contains("зал") || combinedText.contains("йога") ||
           combinedText.contains("растяжка") || combinedText.contains("шаги") ||
           goal.icon.contains("figure") || goal.icon.contains("dumbbell") {
            userProfile.characterStats.updateStat(for: .physical, change: totalGain)
        }
        
        // ИНТЕЛЛЕКТ
        if combinedText.contains("книга") || combinedText.contains("учить") ||
           combinedText.contains("курс") || combinedText.contains("язык") ||
           combinedText.contains("обучение") || combinedText.contains("читать") ||
           combinedText.contains("код") || combinedText.contains("документация") ||
           goal.icon.contains("book") || goal.icon.contains("graduationcap") {
            userProfile.characterStats.updateStat(for: .mental, change: totalGain)
        }
        
        // ЗДОРОВЬЕ
        if combinedText.contains("вода") || combinedText.contains("сон") ||
           combinedText.contains("здоров") || combinedText.contains("витамин") ||
           combinedText.contains("питание") || combinedText.contains("сахар") ||
           goal.icon.contains("heart") || goal.icon.contains("drop") ||
           goal.icon.contains("bed") || goal.icon.contains("leaf") {
            userProfile.characterStats.updateStat(for: .health, change: totalGain)
        }
        
        // КАРЬЕРА
        if combinedText.contains("работа") || combinedText.contains("бизнес") ||
           combinedText.contains("проект") || combinedText.contains("встреч") ||
           combinedText.contains("клиент") || combinedText.contains("финанс") ||
           combinedText.contains("рабоч") || goal.icon.contains("briefcase") ||
           goal.icon.contains("chart") {
            userProfile.characterStats.updateStat(for: .career, change: totalGain)
        }
        
        // СОЦИАЛЬНАЯ ЖИЗНЬ
        if combinedText.contains("семья") || combinedText.contains("друзья") ||
           combinedText.contains("звонок") || combinedText.contains("супруг") ||
           combinedText.contains("дети") || combinedText.contains("родител") ||
           combinedText.contains("свидание") || goal.icon.contains("person") ||
           goal.icon.contains("heart.fill") || goal.icon.contains("house") {
            userProfile.characterStats.updateStat(for: .social, change: totalGain)
        }
        
        saveProfile()
    }
}
