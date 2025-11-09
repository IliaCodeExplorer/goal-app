//
//  RewardsView.swift
//  GoalTracker
//
//  Created by Ilyas on 11/7/25.
//

import SwiftUI

struct RewardsView: View {
    var body: some View {
        RewardsShopView()
    }
}

#Preview {
    RewardsView()
        .environmentObject(GoalManager())
}
