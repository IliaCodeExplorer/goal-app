//
//  IconPicker.swift
//  GoalTracker
//
//  Created by Ilyas on 11/5/25.
//

import SwiftUI

struct IconPicker: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) var dismiss
    
    let icons = [
        "target", "star.fill", "flag.fill", "heart.fill",
        "bolt.fill", "flame.fill", "drop.fill", "leaf.fill",
        "moon.stars.fill", "sun.max.fill", "cloud.fill", "sparkles",
        "book.fill", "pencil", "paintbrush.fill", "music.note",
        "dumbbell.fill", "figure.run", "bicycle", "sportscourt.fill",
        "fork.knife", "cup.and.saucer.fill", "wineglass.fill", "cart.fill",
        "house.fill", "building.2.fill", "car.fill", "airplane",
        "phone.fill", "envelope.fill", "bubble.left.fill", "video.fill",
        "camera.fill", "photo.fill", "wand.and.stars", "gift.fill",
        "briefcase.fill", "laptopcomputer", "desktopcomputer", "printer.fill",
        "gamecontroller.fill", "headphones", "speaker.wave.3.fill", "tv.fill",
        "checkmark.circle.fill", "xmark.circle.fill", "plus.circle.fill", "minus.circle.fill",
        "crown.fill", "crown", "shield.fill", "medal.fill"
    ]
    
    let columns = [
        GridItem(.adaptive(minimum: 60))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(icons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                            dismiss()
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: icon)
                                    .font(.system(size: 30))
                                    .foregroundColor(selectedIcon == icon ? .blue : .primary)
                                    .frame(width: 60, height: 60)
                                    .background(
                                        selectedIcon == icon ?
                                        Color.blue.opacity(0.2) : Color.gray.opacity(0.1)
                                    )
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Выберите иконку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}
