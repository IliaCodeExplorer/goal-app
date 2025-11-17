//
//  Enums.swift
//  GoalTracker
//
//  Created by Ilyas on 11/16/25.
//

import Foundation
import SwiftUI

// MARK: - Frequency
enum Frequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

// MARK: - Tracking Type
enum TrackingType: String, Codable, CaseIterable {
    case binary = "Yes/No"
    case numeric = "Number"
    case habit = "Habit"
    
    var icon: String {
        switch self {
        case .binary: return "checkmark.circle"
        case .numeric: return "number.circle"
        case .habit: return "repeat.circle"
        }
    }
    
    // ← ДОБАВЬ ЭТО СВОЙСТВО
    var description: String {
        switch self {
        case .binary: return "Да или нет"
        case .numeric: return "Числовое значение"
        case .habit: return "Повторяющаяся привычка"
        }
    }
}
// MARK: - Difficulty
enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case epic = "Epic"
    
    var emoji: String {
        switch self {
        case .easy: return "🟢"
        case .medium: return "🟡"
        case .hard: return "🔴"
        case .epic: return "🟣"
        }
    }
    
    var coinMultiplier: Int {
        switch self {
        case .easy: return 10
        case .medium: return 25
        case .hard: return 50
        case .epic: return 100
        }
    }
    
    var color: String {
        switch self {
        case .easy: return "green"
        case .medium: return "yellow"
        case .hard: return "red"
        case .epic: return "purple"
        }
    }
    
    // ← ДОБАВЬ ЭТО СВОЙСТВО
    var description: String {
        switch self {
        case .easy: return "Простая цель"
        case .medium: return "Средняя сложность"
        case .hard: return "Сложная цель"
        case .epic: return "Эпическая цель"
        }
    }
}
