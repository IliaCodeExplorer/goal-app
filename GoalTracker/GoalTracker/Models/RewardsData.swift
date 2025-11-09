import Foundation

class RewardsManager {
    static let shared = RewardsManager()
    
    // Дефолтные виртуальные награды (НЕПОВТОРЯЕМЫЕ)
    let defaultVirtualRewards: [Reward] = [
        Reward(title: "Темная тема", description: "Элегантный темный интерфейс", cost: 100, icon: "moon.stars.fill", category: .virtual, isReusable: false),
        Reward(title: "Пак иконок: Природа", description: "20 иконок природы", cost: 75, icon: "leaf.fill", category: .virtual, isReusable: false),
        Reward(title: "Пак иконок: Спорт", description: "20 спортивных иконок", cost: 75, icon: "figure.run", category: .virtual, isReusable: false),
        Reward(title: "Пак иконок: Бизнес", description: "20 бизнес иконок", cost: 75, icon: "briefcase.fill", category: .virtual, isReusable: false),
        Reward(title: "Золотая тема", description: "Премиум золотая тема", cost: 200, icon: "sparkles", category: .virtual, isReusable: false),
        Reward(title: "Спецэффект: Фейерверк", description: "Красивый эффект при завершении", cost: 150, icon: "fireworks", category: .virtual, isReusable: false),
        Reward(title: "Звуковые эффекты", description: "Включить звуки успеха", cost: 100, icon: "speaker.wave.3.fill", category: .virtual, isReusable: false),
    ]
    
    // Примеры реальных наград (ПОВТОРЯЕМЫЕ - можно покупать снова и снова!)
    let defaultRealRewards: [Reward] = [
        // ЕДА (многоразовые)
        Reward(title: "☕ Кофе с пирожным", description: "Вкусный перерыв в любимой кофейне", cost: 150, icon: "cup.and.saucer.fill", category: .food, isReusable: true),
        Reward(title: "🍫 Любимое сладкое", description: "Маленькая радость для себя", cost: 50, icon: "heart.fill", category: .food, isReusable: true),
        Reward(title: "🍕 Вкусный ужин", description: "Заказать любимую еду", cost: 200, icon: "fork.knife", category: .food, isReusable: true),
        Reward(title: "🍰 Торт в кондитерской", description: "Особенный десерт", cost: 300, icon: "birthday.cake", category: .food, isReusable: true),
        Reward(title: "🍔 Фастфуд без вины", description: "Побаловать себя бургером", cost: 100, icon: "menucard.fill", category: .food, isReusable: true),
        Reward(title: "🍣 Суши", description: "Заказать роллы", cost: 400, icon: "fish.fill", category: .food, isReusable: true),
        
        // РАЗВЛЕЧЕНИЯ (многоразовые)
        Reward(title: "🎮 1 час игры", description: "Время для любимой игры без вины", cost: 100, icon: "gamecontroller.fill", category: .entertainment, isReusable: true),
        Reward(title: "🎮 3 часа игры", description: "Долгая игровая сессия", cost: 250, icon: "gamecontroller.fill", category: .entertainment, isReusable: true),
        Reward(title: "🎬 Поход в кино", description: "Билет на новый фильм", cost: 300, icon: "film.fill", category: .entertainment, isReusable: true),
        Reward(title: "📺 Сериал-марафон", description: "Вечер любимых сериалов", cost: 150, icon: "tv.fill", category: .entertainment, isReusable: true),
        Reward(title: "📚 Новая книга", description: "Купить книгу которую хотел", cost: 400, icon: "book.fill", category: .entertainment, isReusable: true),
        Reward(title: "🎵 Концерт", description: "Билет на любимого исполнителя", cost: 1500, icon: "music.note", category: .entertainment, isReusable: true),
        Reward(title: "🎪 Развлекательное мероприятие", description: "Выставка, театр, стендап", cost: 800, icon: "theatermasks.fill", category: .entertainment, isReusable: true),
        
        // ЗАБОТА О СЕБЕ (многоразовые)
        Reward(title: "💆 Массаж", description: "Расслабляющий массаж", cost: 800, icon: "hands.sparkles.fill", category: .selfCare, isReusable: true),
        Reward(title: "💅 Маникюр/Педикюр", description: "Уход за собой", cost: 500, icon: "hand.raised.fill", category: .selfCare, isReusable: true),
        Reward(title: "💇 Стрижка/Укладка", description: "Новый образ", cost: 600, icon: "scissors", category: .selfCare, isReusable: true),
        Reward(title: "🧖 СПА день", description: "Полный день релакса", cost: 1500, icon: "humidity.fill", category: .selfCare, isReusable: true),
        Reward(title: "😴 День ничегонеделания", description: "Отдых без вины", cost: 200, icon: "bed.double.fill", category: .selfCare, isReusable: true),
        Reward(title: "🛀 Расслабляющая ванна", description: "Ванна с бомбочкой и свечами", cost: 100, icon: "drop.fill", category: .selfCare, isReusable: true),
        
        // ФИТНЕС
        Reward(title: "🏊 Бассейн", description: "День в бассейне или сауне", cost: 400, icon: "figure.pool.swim", category: .fitness, isReusable: true),
        Reward(title: "🧗 Скалодром", description: "Активный отдых", cost: 500, icon: "figure.climbing", category: .fitness, isReusable: true),
        Reward(title: "🎾 Спортивная игра", description: "Теннис, бадминтон, боулинг", cost: 300, icon: "tennis.racket", category: .fitness, isReusable: true),
        
        // СОЦИАЛЬНОЕ (многоразовые)
        Reward(title: "🍽️ Ужин с друзьями", description: "Встреча в ресторане", cost: 600, icon: "person.3.fill", category: .social, isReusable: true),
        Reward(title: "🎉 Вечеринка", description: "Организовать встречу", cost: 1000, icon: "party.popper.fill", category: .social, isReusable: true),
        Reward(title: "☕ Кофе с другом", description: "Качественное время вместе", cost: 200, icon: "cup.and.saucer.fill", category: .social, isReusable: true),
        
        // ПОКУПКИ (обычно одноразовые)
        Reward(title: "👟 Новые кроссовки", description: "Обновить спортивную обувь", cost: 2000, icon: "figure.walk", category: .shopping, isReusable: false),
        Reward(title: "👕 Новая одежда", description: "Купить то что нравится", cost: 1500, icon: "tshirt.fill", category: .shopping, isReusable: false),
        Reward(title: "🎧 Наушники", description: "Хорошие наушники", cost: 3000, icon: "headphones", category: .shopping, isReusable: false),
        Reward(title: "⌚ Часы/Аксессуар", description: "Стильный аксессуар", cost: 2500, icon: "applewatch", category: .shopping, isReusable: false),
        Reward(title: "🎒 Рюкзак/Сумка", description: "Качественная сумка", cost: 2000, icon: "backpack.fill", category: .shopping, isReusable: false),
        
        // БОЛЬШИЕ ЦЕЛИ (одноразовые)
        Reward(title: "🚗 Тест-драйв машины мечты", description: "Записаться на тест-драйв", cost: 1000, icon: "car.fill", category: .bigGoal, isReusable: false),
        Reward(title: "✈️ Выходные в другом городе", description: "Короткое путешествие", cost: 5000, icon: "airplane", category: .bigGoal, isReusable: false),
        Reward(title: "💻 Новый гаджет", description: "iPad, часы или другая техника", cost: 10000, icon: "iphone", category: .bigGoal, isReusable: false),
        Reward(title: "🏖️ Отпуск", description: "Неделя отдыха на море", cost: 20000, icon: "sun.max.fill", category: .bigGoal, isReusable: false),
        Reward(title: "🎓 Курс/Обучение", description: "Инвестиция в себя", cost: 8000, icon: "graduationcap.fill", category: .bigGoal, isReusable: false),
        Reward(title: "🏠 Улучшение дома", description: "Ремонт или новая мебель", cost: 15000, icon: "house.fill", category: .bigGoal, isReusable: false),
    ]
}
