//
//  Reward.swift
//  GoalTracker
//
//  Created by Ilyas on 11/5/25.
//

import Foundation

class RewardsManager {
    static let shared = RewardsManager()
    
    // Дефолтные виртуальные награды
    let defaultVirtualRewards: [Reward] = [
        Reward(title: "Темная тема", description: "Элегантный темный интерфейс", cost: 100, icon: "moon.stars.fill", category: .virtual),
        Reward(title: "Пак иконок: Природа", description: "20 иконок природы", cost: 75, icon: "leaf.fill", category: .virtual),
        Reward(title: "Пак иконок: Спорт", description: "20 спортивных иконок", cost: 75, icon: "figure.run", category: .virtual),
        Reward(title: "Золотая тема", description: "Премиум золотая тема", cost: 200, icon: "sparkles", category: .virtual),
        Reward(title: "Спецэффект: Фейерверк", description: "Красивый эффект при завершении", cost: 150, icon: "fireworks", category: .virtual),
    ]
    
    // Примеры реальных наград (пользователь может добавить свои)
    let defaultRealRewards: [Reward] = [
        // Еда
        Reward(title: "☕ Кофе с пирожным", description: "Вкусный перерыв в любимой кофейне", cost: 150, icon: "cup.and.saucer.fill", category: .food),
        Reward(title: "🍫 Любимое сладкое", description: "Маленькая радость для себя", cost: 50, icon: "heart.fill", category: .food),
        Reward(title: "🍕 Вкусный ужин", description: "Заказать любимую еду", cost: 200, icon: "fork.knife", category: .food),
        Reward(title: "🍰 Торт в кондитерской", description: "Особенный десерт", cost: 300, icon: "birthday.cake", category: .food),
        
        // Развлечения
        Reward(title: "🎮 1 час игры", description: "Время для любимой игры без вины", cost: 100, icon: "gamecontroller.fill", category: .entertainment),
        Reward(title: "🎬 Поход в кино", description: "Билет на новый фильм", cost: 300, icon: "film.fill", category: .entertainment),
        Reward(title: "📚 Новая книга", description: "Купить книгу которую хотел", cost: 400, icon: "book.fill", category: .entertainment),
        Reward(title: "🎵 Концерт", description: "Билет на любимого исполнителя", cost: 1500, icon: "music.note", category: .entertainment),
        
        // Фитнес
        Reward(title: "💆 Массаж", description: "Расслабляющий массаж", cost: 800, icon: "hands.sparkles.fill", category: .fitness),
        Reward(title: "🏊 Бассейн", description: "День в бассейне или сауне", cost: 400, icon: "figure.pool.swim", category: .fitness),
        
        // Покупки
        Reward(title: "👟 Новые кроссовки", description: "Обновить спортивную обувь", cost: 2000, icon: "figure.walk", category: .shopping),
        Reward(title: "👕 Новая одежда", description: "Купить то что нравится", cost: 1500, icon: "tshirt.fill", category: .shopping),
        Reward(title: "🎧 Наушники", description: "Хорошие наушники", cost: 3000, icon: "headphones", category: .shopping),
        
        // Большие цели
        Reward(title: "🚗 Тест-драйв машины мечты", description: "Записаться на тест-драйв", cost: 1000, icon: "car.fill", category: .bigGoal),
        Reward(title: "✈️ Выходные в другом городе", description: "Короткое путешествие", cost: 5000, icon: "airplane", category: .bigGoal),
        Reward(title: "💻 Новый гаджет", description: "iPad, часы или другая техника", cost: 10000, icon: "iphone", category: .bigGoal),
        Reward(title: "🏖️ Отпуск", description: "Неделя отдыха на море", cost: 20000, icon: "sun.max.fill", category: .bigGoal),
    ]
}
