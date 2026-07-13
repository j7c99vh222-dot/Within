import Foundation

struct NutritionFood: Identifiable, Decodable {
    let id: String
    let name: String
    let group: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double?

    var carbohydrate: Double { carbs }
}

enum NutritionFoodLibrary {
    static let all: [NutritionFood] = {
        let nested = Bundle.main.url(forResource: "nutrition-foods", withExtension: "json", subdirectory: "Nutrition")
        let url = nested ?? Bundle.main.url(forResource: "nutrition-foods", withExtension: "json")
        guard let url,
              let data = try? Data(contentsOf: url),
              let foods = try? JSONDecoder().decode([NutritionFood].self, from: data),
              !foods.isEmpty else {
            return fallback
        }
        return foods
    }()

    private static let fallback = [
        NutritionFood(id: "oats", name: "Rolled oats, dry", group: "Whole grains", calories: 379, protein: 13.2, carbs: 67.7, fat: 6.5, fiber: 10.1, sugar: nil),
        NutritionFood(id: "lentils", name: "Lentils, cooked", group: "Beans and lentils", calories: 116, protein: 9, carbs: 20.1, fat: 0.4, fiber: 7.9, sugar: nil),
        NutritionFood(id: "salmon", name: "Salmon, cooked", group: "Protein", calories: 206, protein: 22.1, carbs: 0, fat: 12.4, fiber: 0, sugar: nil)
    ]
}
