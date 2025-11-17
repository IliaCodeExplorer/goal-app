import Foundation

class RewardsManager {
    static let shared = RewardsManager()
    
    // Предустановленные награды
    let defaultRewards: [Reward] = [
        // МГНОВЕННЫЕ (маленькие радости)
        Reward(
            title: "☕ Кофе с десертом",
            description: "Любимый напиток в кофейне",
            cost: 150,
            icon: "cup.and.saucer.fill",
            category: .instant
        ),
        Reward(
            title: "🍫 Сладкое без вины",
            description: "Заслуженное лакомство",
            cost: 50,
            icon: "birthday.cake.fill",
            category: .instant
        ),
        Reward(
            title: "🎮 Час игры",
            description: "Время на любимую игру",
            cost: 100,
            icon: "gamecontroller.fill",
            category: .instant
        ),
        Reward(
            title: "📺 Сериал вечером",
            description: "Отдых перед экраном",
            cost: 75,
            icon: "tv.fill",
            category: .instant
        ),
        Reward(
            title: "😴 Поспать днем",
            description: "Заслуженный отдых",
            cost: 100,
            icon: "bed.double.fill",
            category: .instant
        ),
        
        // ВПЕЧАТЛЕНИЯ (средние награды)
        Reward(
            title: "🎬 Поход в кино",
            description: "Новый фильм на большом экране",
            cost: 300,
            icon: "film.fill",
            category: .experience
        ),
        Reward(
            title: "🍕 Ужин в ресторане",
            description: "Вкусная еда без готовки",
            cost: 400,
            icon: "fork.knife",
            category: .experience
        ),
        Reward(
            title: "💆 Массаж",
            description: "Расслабление и забота о себе",
            cost: 600,
            icon: "hands.sparkles.fill",
            category: .experience
        ),
        Reward(
            title: "🏊 День в спа",
            description: "Полное расслабление",
            cost: 800,
            icon: "drop.fill",
            category: .experience
        ),
        
        // ПОКУПКИ (материальные награды)
        Reward(
            title: "📚 Новая книга",
            description: "Книга которую давно хотел",
            cost: 250,
            icon: "book.fill",
            category: .purchase
        ),
        Reward(
            title: "👕 Новая одежда",
            description: "Обновить гардероб",
            cost: 1000,
            icon: "tshirt.fill",
            category: .purchase
        ),
        Reward(
            title: "👟 Новая обувь",
            description: "Качественная обувь",
            cost: 1500,
            icon: "shoeprints.fill",
            category: .purchase
        ),
        Reward(
            title: "🎧 Наушники",
            description: "Хороший звук для себя",
            cost: 2000,
            icon: "headphones",
            category: .purchase
        ),
        
        // БОЛЬШИЕ ЦЕЛИ
        Reward(
            title: "🚗 Тест-драйв мечты",
            description: "Прокатиться на машине мечты",
            cost: 3000,
            icon: "car.fill",
            category: .bigGoal
        ),
        Reward(
            title: "✈️ Путешествие",
            description: "Выходные в другом городе",
            cost: 5000,
            icon: "airplane",
            category: .bigGoal
        ),
        Reward(
            title: "📱 Новый гаджет",
            description: "Телефон, планшет, часы",
            cost: 10000,
            icon: "iphone",
            category: .bigGoal
        ),
        Reward(
            title: "🏖️ Отпуск на море",
            description: "Неделя полного отдыха",
            cost: 20000,
            icon: "sun.max.fill",
            category: .bigGoal
        )
    ]
}
