////
////  MainTabView.swift
////  GoalTracker
////
////  Created by Ilyas on 11/7/25.
////
//
//import SwiftUI
//
//struct MainTabView: View {
//    @StateObject private var goalManager = GoalManager()
//    
//    var body: some View {
//        TabView {
//            // Dashboard Tab
//            DashboardView()
//                .tabItem {
//                    Label("Цели", systemImage: "target")
//                }
//            
//            // Statistics Tab
//            StatisticsView()
//                .tabItem {
//                    Label("Статистика", systemImage: "chart.bar.fill")
//                }
//            
//            // Rewards Tab
//            RewardsView()
//                .tabItem {
//                    Label("Награды", systemImage: "gift.fill")
//                }
//            
//            // Profile Tab
//            ProfileView()
//                .tabItem {
//                    Label("Профиль", systemImage: "person.fill")
//                }
//        }
//        .environmentObject(goalManager)
//    }
//}
//
//#Preview {
//    MainTabView()
//}
