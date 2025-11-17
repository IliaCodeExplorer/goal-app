//
//  GoalManager+Rewards.swift
//  GoalTracker
//
//  Created by Ilyas on 11/17/25.
//

import Foundation
import UIKit

// MARK: - Reward Management
extension GoalManager {
    
    func purchaseReward(_ reward: Reward) -> Bool {
        guard userProfile.coins >= reward.cost else { return false }
        
        userProfile.coins -= reward.cost
        
        if let index = rewards.firstIndex(where: { $0.id == reward.id }) {
            let record = PurchaseRecord(cost: reward.cost)
            rewards[index].purchaseHistory.append(record)
        }
        
        saveRewards()
        saveProfile()
        
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
}
