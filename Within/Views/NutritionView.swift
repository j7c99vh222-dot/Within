import PhotosUI
import SwiftUI
import UIKit

struct NutritionView: View {
    enum Goal: String, CaseIterable, Identifiable {
        case lose = "Lose weight"
        case gain = "Gain weight"
        case maintain = "Maintain"
        case healthy = "General health"
        case skin = "Skin support"
        case gut = "Gut health"
        var id: String { rawValue }
    }

    enum Diet: String, CaseIterable, Identifiable {
        case none = "No accommodation"
        case vegetarian = "Vegetarian"
        case vegan = "Vegan"
        case pescatarian = "Pescatarian"
        case mediterranean = "Mediterranean"
        case paleo = "Paleo"
        case keto = "Keto"
        case halal = "Halal"
        case kosher = "Kosher"
        var id: String { rawValue }
    }

    @EnvironmentObject private var app: AppModel
    @State private var goal: Goal = .healthy
    @State private var diet: Diet = .none
    @State private var weight = 70.0
    @State private var height = 170.0
    @State private var age = 30.0
    @State private var bodyFat = ""
    @State private var search = ""
    @State private var grams = 100.0
    @State private var selectedFood: NutritionFood?
    @State private var foodLog: [FoodLogItem] = []
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var privatePhotoData: Data?
    @State private var showMealReset = false
    @State private var showProgressPhoto = false
    @State private var mealDescription = ""
    @State private var mealReview = ""
    @State private var mealReviewBusy = false

    private let foods = NutritionFoodLibrary.all

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                goalPicker
                measurements
                targets
                hydrationPanel
                principles
                workoutPanel
                photoPanel
                foodTracker
                mealReflectionPanel
                mealResetButton
                recommendations
                sourceFooter
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 20)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Nutrition")
        .navigationBarTitleDisplayMode(.inline)
        .withinScreen()
        .task {
            privatePhotoData = await PrivateStore.shared.loadProgressPhoto()
            foodLog = await PrivateStore.shared.loadFoodLog()
            weight = app.healthWeightKilograms
            app.refreshDailyState()
            app.updateHydrationGoal(for: weight)
        }
        .onChange(of: weight) { _, value in
            app.updateHydrationGoal(for: value)
        }
        .onChange(of: selectedPhoto) { _, item in
            guard let item else { return }
            Task {
                guard let data = try? await item.loadTransferable(type: Data.self) else { return }
                privatePhotoData = data
                try? await PrivateStore.shared.saveProgressPhoto(data)
            }
        }
        .sheet(isPresented: $showMealReset) {
            MealResetView()
                .environmentObject(app)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showProgressPhoto) {
            if let privatePhotoData {
                ProgressPhotoViewer(photoData: privatePhotoData)
                    .environmentObject(app)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Eyebrow(text: "Nutrition path · adult estimates")
            Text("Use food to support your life, not punish it.")
                .font(.system(size: 34, weight: .medium, design: .serif))
            Text("Build around fiber-rich variety, adequate protein, lower added sugar, regular meals, and enough total energy.")
                .font(.subheadline)
                .foregroundStyle(palette.secondaryText)
        }
    }

    private var goalPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goal")
                .font(.caption.weight(.bold))
            Picker("Goal", selection: $goal) {
                ForEach(Goal.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.menu)
            Divider().overlay(palette.line)
            Text("Diet accommodation")
                .font(.caption.weight(.bold))
            Picker("Diet accommodation", selection: $diet) {
                ForEach(Diet.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.menu)
            Text(dietNote)
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
        }
        .padding(18)
        .withinSurface()
    }

    private var measurements: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                metricField("Weight", value: $weight, suffix: "kg")
                metricField("Height", value: $height, suffix: "cm")
                metricField("Age", value: $age, suffix: "yr")
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("Body fat percentage (optional)")
                    .font(.caption.weight(.semibold))
                TextField("If known", text: $bodyFat)
                    .keyboardType(.decimalPad)
                    .padding(11)
                    .background(palette.background)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))
            }
            Text("BMI \(bmi, format: .number.precision(.fractionLength(1))) · \(bmiLabel). BMI is a screening measure and does not diagnose health or body composition.")
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
        }
        .padding(18)
        .withinSurface()
    }

    private func metricField(_ title: String, value: Binding<Double>, suffix: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2.weight(.bold))
            TextField(title, value: value, format: .number.precision(.fractionLength(0)))
                .keyboardType(.decimalPad)
                .padding(10)
                .background(palette.background)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))
            Text(suffix)
                .font(.caption2)
                .foregroundStyle(palette.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var targets: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Eyebrow(text: "Gentle daily starting point")
                Spacer()
                Text("Adjust with outcomes and care")
                    .font(.caption2)
                    .foregroundStyle(palette.secondaryText)
            }
            HStack {
                targetMetric("Calories", value: "\(Int(calorieTarget))", unit: "kcal")
                targetMetric("Protein", value: "\(Int(proteinTarget))", unit: "g")
                targetMetric("Fiber", value: "\(Int(fiberTarget))", unit: "g")
            }
            Text("These are broad estimates, not prescriptions. Pregnancy, adolescence, eating disorders, diabetes, kidney disease, medications, and major weight change require individualized care.")
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
        }
        .padding(18)
        .background(Color(hex: 0x0A2449))
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func targetMetric(_ title: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white.opacity(0.65))
            Text(value)
                .font(.system(.title2, design: .serif))
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var hydrationPanel: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Eyebrow(text: "Daily hydration reminder")
                    Text("\(app.waterConsumedLiters, format: .number.precision(.fractionLength(1...2))) of \(app.waterGoalLiters, format: .number.precision(.fractionLength(1...2))) L")
                        .font(.system(.title2, design: .serif))
                }
                Spacer()
                Image(systemName: "drop.fill")
                    .font(.title2)
                    .foregroundStyle(palette.accent)
            }
            HStack(spacing: 9) {
                ForEach(1...4, id: \.self) { milestone in
                    Button {
                        app.setWaterMilestone(app.waterMilestones == milestone ? milestone - 1 : milestone)
                    } label: {
                        VStack(spacing: 7) {
                            Image(systemName: milestone <= app.waterMilestones ? "drop.fill" : "drop")
                                .font(.title3)
                            Text("\(app.waterGoalLiters / 4, format: .number.precision(.fractionLength(1...2))) L")
                                .font(.system(size: 9, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .background(milestone <= app.waterMilestones ? palette.accentSoft : palette.background)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(milestone <= app.waterMilestones ? palette.accent : palette.line))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Hydration milestone \(milestone) of 4")
                }
            }
            Text("The four buttons are equal milestones across the day, not instructions to drink a large amount at once. This 30 mL/kg reminder is a broad planning heuristic capped at 1.5–4 L. Total water also comes from food and other drinks; climate, activity, pregnancy, illness, and kidney or heart conditions can change needs.")
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
                .lineSpacing(3)
            Link("National Academies · Total water context", destination: URL(string: "https://www.nationalacademies.org/read/10925/chapter/2")!)
                .font(.caption.weight(.semibold))
        }
        .padding(18)
        .withinSurface(emphasized: app.theme == .spiritual)
    }

    private var principles: some View {
        VStack(spacing: 0) {
            principle("01", "Fiber first", "Beans, whole grains, vegetables, fruit, nuts, and seeds support bowel function and feed gut microbes. Increase gradually.")
            Divider().overlay(palette.line)
            principle("02", "Protein forward", "Adequate protein supports tissue and meal satisfaction. More is not automatically better.")
            Divider().overlay(palette.line)
            principle("03", "Lower added sugar", "Look at added sugar in context. Fruit and plain dairy are not nutritionally equivalent to candy or soda.")
        }
        .withinSurface()
    }

    private var workoutPanel: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Eyebrow(text: "Today's movement record")
                    Text("Did you train, recover, or leave the day unfinished?")
                        .font(.system(.title3, design: .serif))
                }
                Spacer()
                Image(systemName: "dumbbell").foregroundStyle(palette.accent)
            }
            Text("A rest day can be deliberate. An unplanned day can be resumed tomorrow without repayment.")
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
            HStack(spacing: 9) {
                workoutStatusButton("trained", title: "I trained today", symbol: "checkmark")
                workoutStatusButton("rest", title: "Rest or recovery", symbol: "moon")
            }
            if app.workoutStatus == "trained" {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(WorkoutArea.allCases) { area in
                        Button {
                            app.toggleWorkoutArea(area)
                        } label: {
                            HStack {
                                Image(systemName: app.completedWorkoutAreas.contains(area) ? "checkmark.square.fill" : "square")
                                Text(area.rawValue)
                                Spacer()
                            }
                            .font(.caption.weight(.semibold))
                            .frame(minHeight: 38)
                            .padding(.horizontal, 10)
                            .background(app.completedWorkoutAreas.contains(area) ? palette.accentSoft : palette.background)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(app.completedWorkoutAreas.contains(area) ? palette.accent : palette.line))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            Label("This record turns over with tomorrow's daily ritual.", systemImage: "calendar")
                .font(.caption2)
                .foregroundStyle(palette.secondaryText)
        }
        .padding(18)
        .withinSurface()
    }

    private func workoutStatusButton(_ status: String, title: String, symbol: String) -> some View {
        Button {
            app.setWorkoutStatus(status)
        } label: {
            Label(title, systemImage: symbol)
                .font(.caption.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 46)
                .background(app.workoutStatus == status ? palette.accentSoft : palette.background)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(app.workoutStatus == status ? palette.accent : palette.line))
        }
        .buttonStyle(.plain)
    }

    private func principle(_ number: String, _ title: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 13) {
            Text(number)
                .font(.caption.monospacedDigit())
                .foregroundStyle(palette.accent)
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                Text(text)
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
            }
        }
        .padding(16)
    }

    private var photoPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Eyebrow(text: "Private progress photo")
                    Text("Body, face, or skin")
                        .font(.system(.title3, design: .serif))
                }
                Spacer()
                Image(systemName: "lock.fill")
                    .foregroundStyle(palette.accent)
            }
            if privatePhotoData != nil {
                Button {
                    showProgressPhoto = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.rectangle")
                            .font(.title3)
                            .foregroundStyle(palette.accent)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Private photo saved")
                                .font(.headline)
                                .foregroundStyle(palette.text)
                            Text("Tap to view it only when you choose.")
                                .font(.caption)
                                .foregroundStyle(palette.secondaryText)
                        }
                        Spacer()
                        Image(systemName: "eye")
                            .foregroundStyle(palette.secondaryText)
                    }
                    .padding(14)
                    .background(palette.background)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))
                }
                .buttonStyle(.plain)
            }
            HStack {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label(privatePhotoData == nil ? "Choose photo" : "Replace photo", systemImage: "photo")
                }
                .buttonStyle(.bordered)
                if privatePhotoData != nil {
                    Button("Delete", role: .destructive) {
                        privatePhotoData = nil
                        Task { try? await PrivateStore.shared.deleteProgressPhoto() }
                    }
                }
            }
            Text("Stored with iOS complete file protection on this device. It is never posted to Community.")
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
        }
        .padding(18)
        .withinSurface()
    }

    private var foodTracker: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Eyebrow(text: "Food tracker · \(foods.count) everyday foods")
                Text("Name what was on the plate. Let the numbers stay approximate.")
                    .font(.system(.title3, design: .serif))
            }
            Text("Values are per 100 g from generic USDA references. Preparation, variety, and brand can change them.")
                .font(.caption2)
                .foregroundStyle(palette.secondaryText)
            TextField("Search oats, lentils, salmon...", text: $search)
                .padding(11)
                .background(palette.background)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))

            if !search.isEmpty {
                ForEach(filteredFoods.prefix(6)) { food in
                    Button {
                        selectedFood = food
                        search = food.name
                    } label: {
                        HStack {
                            Text(food.name)
                            Spacer()
                            Text("\(Int(food.fiber)) g fiber / 100 g")
                                .font(.caption2)
                                .foregroundStyle(palette.secondaryText)
                        }
                        .frame(minHeight: 40)
                    }
                    .buttonStyle(.plain)
                    Divider().overlay(palette.line)
                }
            }

            if let selectedFood {
                HStack {
                    TextField("Grams", value: $grams, format: .number.precision(.fractionLength(0)))
                        .keyboardType(.decimalPad)
                        .padding(11)
                        .background(palette.background)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))
                    Button("Add \(selectedFood.name)") { addFood(selectedFood) }
                        .buttonStyle(.borderedProminent)
                }
            }

            if !foodLog.isEmpty {
                Divider().overlay(palette.line)
                HStack {
                    macro("Calories", totalCalories, "kcal")
                    macro("Protein", totalProtein, "g")
                    macro("Fiber", totalFiber, "g")
                }
                ForEach(foodLog) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name).font(.subheadline.weight(.semibold))
                            Text("\(Int(item.grams)) g · \(Int(item.calories)) kcal · \(item.fiber, format: .number.precision(.fractionLength(1))) g fiber")
                                .font(.caption2)
                                .foregroundStyle(palette.secondaryText)
                        }
                        Spacer()
                        Button(role: .destructive) { removeFood(item.id) } label: { Image(systemName: "trash") }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .padding(18)
        .withinSurface()
    }

    private func macro(_ title: String, _ value: Double, _ unit: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.caption2).foregroundStyle(palette.secondaryText)
            Text("\(Int(value)) \(unit)").font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mealResetButton: some View {
        Button {
            showMealReset = true
        } label: {
            HStack {
                Image(systemName: "heart.circle")
                VStack(alignment: .leading, spacing: 3) {
                    Text("Panicking about a meal?")
                        .font(.headline)
                    Text("Reset without punishment or compensation.")
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                }
                Spacer()
                Image(systemName: "arrow.right")
            }
            .padding(17)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(palette.danger.opacity(0.55)))
        }
        .buttonStyle(.plain)
    }

    private var mealReflectionPanel: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 10) {
                Text(app.companion.symbol)
                    .font(.title2)
                    .frame(width: 42, height: 42)
                    .background(palette.accentSoft)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Eyebrow(text: "\(app.companion.name) · meal reflection")
                    Text("See the pattern without grading yourself.")
                        .font(.system(.title3, design: .serif))
                }
            }
            TextField("Brown rice, salmon, broccoli, olive oil, and berries...", text: $mealDescription, axis: .vertical)
                .lineLimit(2...5)
                .padding(11)
                .background(palette.background)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))
            if !foodLog.isEmpty {
                Text("Calculated generic log: \(Int(totalCalories)) kcal · \(Int(totalProtein)) g protein · \(Int(totalCarbohydrate)) g carbohydrate · \(Int(totalFat)) g fat · \(totalFiber, format: .number.precision(.fractionLength(1))) g fiber")
                    .font(.caption2)
                    .foregroundStyle(palette.secondaryText)
            }
            Button {
                Task { await reviewMeal() }
            } label: {
                Group {
                    if mealReviewBusy { ProgressView() }
                    else { Label(mealDescription.isEmpty ? "Reflect on today's log" : "Reflect on this meal", systemImage: "sparkles") }
                }
                .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .disabled(mealReviewBusy || (mealDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && foodLog.isEmpty))
            if !mealReview.isEmpty {
                Text(mealReview)
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
                    .lineSpacing(4)
                    .padding(13)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(palette.background)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))
            }
            Text("Ingredients, preparation, brands, absorption, and portions create uncertainty. This is nutrition literacy, not medical nutrition therapy.")
                .font(.caption2)
                .foregroundStyle(palette.secondaryText)
        }
        .padding(18)
        .withinSurface(emphasized: app.theme == .spiritual)
    }

    private var recommendations: some View {
        VStack(alignment: .leading, spacing: 12) {
            Eyebrow(text: "Today's table · \(goal.rawValue)")
            ForEach(Array(dailyRecommendations.enumerated()), id: \.offset) { _, item in
                recommendation(item.0, item.1)
            }
            Text("Tomorrow brings a different pair. Adjust for allergies, culture, budget, religious practice, and tolerance.")
                .font(.caption2)
                .foregroundStyle(palette.secondaryText)
        }
    }

    private func recommendation(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(text).font(.caption).foregroundStyle(palette.secondaryText)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .withinSurface()
    }

    private var sourceFooter: some View {
        VStack(alignment: .leading, spacing: 9) {
            Link("USDA FoodData Central", destination: URL(string: "https://fdc.nal.usda.gov/")!)
            Link("Dietary Guidelines for Americans", destination: URL(string: "https://www.dietaryguidelines.gov/")!)
            Link("NIDDK digestive health", destination: URL(string: "https://www.niddk.nih.gov/health-information/digestive-diseases")!)
        }
        .font(.caption.weight(.semibold))
        .padding(.vertical, 8)
    }

    private var filteredFoods: [NutritionFood] {
        foods.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    private func addFood(_ food: NutritionFood) {
        let scale = max(1, grams) / 100
        foodLog.append(FoodLogItem(id: UUID(), name: food.name, grams: grams, calories: food.calories * scale, protein: food.protein * scale, carbohydrate: food.carbohydrate * scale, fat: food.fat * scale, fiber: food.fiber * scale))
        persistFoodLog()
        search = ""
        selectedFood = nil
        grams = 100
    }

    private func removeFood(_ id: UUID) {
        foodLog.removeAll { $0.id == id }
        persistFoodLog()
    }

    private func persistFoodLog() {
        let snapshot = foodLog
        Task { try? await PrivateStore.shared.saveFoodLog(snapshot) }
    }

    private var bmi: Double { weight / pow(max(1, height) / 100, 2) }
    private var bmiLabel: String {
        switch bmi {
        case ..<18.5: "below the standard screening range"
        case 18.5..<25: "within the standard screening range"
        case 25..<30: "above the standard screening range"
        default: "well above the standard screening range"
        }
    }
    private var calorieTarget: Double {
        let maintenance = max(1_400, weight * 30)
        switch goal {
        case .lose: return max(1_400, maintenance - 300)
        case .gain: return maintenance + 250
        default: return maintenance
        }
    }
    private var proteinTarget: Double { weight * (goal == .gain ? 1.6 : 1.2) }
    private var fiberTarget: Double { max(22, calorieTarget / 1_000 * 14) }
    private var totalCalories: Double { foodLog.reduce(0) { $0 + $1.calories } }
    private var totalProtein: Double { foodLog.reduce(0) { $0 + $1.protein } }
    private var totalFiber: Double { foodLog.reduce(0) { $0 + $1.fiber } }
    private var totalCarbohydrate: Double { foodLog.reduce(0) { $0 + $1.carbohydrate } }
    private var totalFat: Double { foodLog.reduce(0) { $0 + $1.fat } }
    private var dailyRecommendations: [(String, String)] {
        let ideas = [
            ("Oat, berry, and chia bowl", "Oats, plain yogurt or fortified soy yogurt, berries, chia, and nuts. Increase fiber gradually."),
            ("Lentil grain plate", "Lentils, brown rice or quinoa, roasted vegetables, olive oil, and a suitable protein addition."),
            ("Bean and avocado tacos", "Corn tortillas, pinto or black beans, red cabbage, tomato, avocado, and lime."),
            ("Miso tofu soup", "Miso broth, tofu, mushrooms, bok choy, edamame, and brown rice; adjust sodium to context."),
            ("Sardine tomato toast", "Whole-grain toast, sardines, tomato, greens, and lemon; use a plant protein when preferred."),
            ("Buckwheat berry breakfast", "Cooked buckwheat, berries, ground flax, and plain yogurt or a fortified soy alternative."),
            ("Three-color bean soup", "Beans or lentils, carrots, tomato, greens, herbs, and low-sodium stock."),
            ("Tofu vegetable skillet", "Tofu, several vegetables, brown rice, garlic, and a small amount of sesame or olive oil.")
        ]
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        let start = (day + goal.rawValue.count + app.profile.username.count) % ideas.count
        return [ideas[start], ideas[(start + 3) % ideas.count]]
    }

    @MainActor
    private func reviewMeal() async {
        mealReviewBusy = true
        let logSummary = foodLog.map { "\(Int($0.grams)) g \($0.name)" }.joined(separator: ", ")
        let description = mealDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let prompt = "Review this meal without shame. Give a balance rating, estimated macros, fiber, likely micronutrient and polyphenol food sources, what may be missing, one realistic next choice, and clear uncertainty. My goal is \(goal.rawValue), diet accommodation is \(diet.rawValue). Meal: \(description.isEmpty ? logSummary : description). Generic logged totals: \(Int(totalCalories)) kcal, \(Int(totalProtein)) g protein, \(Int(totalCarbohydrate)) g carbohydrate, \(Int(totalFat)) g fat, \(totalFiber) g fiber."
        await app.sendGuideMessage(prompt)
        mealReview = app.guideMessages.last?.text ?? "The reflection could not be prepared."
        mealReviewBusy = false
    }
    private var dietNote: String {
        switch diet {
        case .vegan: "Include reliable vitamin B12 and discuss iron, iodine, calcium, vitamin D, and omega-3 needs with a qualified professional."
        case .vegetarian: "Use varied legumes, dairy or fortified alternatives, eggs if included, whole grains, nuts, seeds, and produce."
        case .keto: "Very-low-carbohydrate diets can be inappropriate with some conditions or medications and may reduce fiber without careful planning."
        case .paleo: "Excluding grains and legumes is not required for health. Replace nutrients and fiber thoughtfully if you avoid them."
        default: "Recommendations adapt to this preference while prioritizing adequacy, variety, and flexibility."
        }
    }
    private var palette: WithinPalette { .palette(for: app.theme) }
}

private struct MealResetView: View {
    @EnvironmentObject private var app: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let palette = WithinPalette.palette(for: app.theme)
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "heart.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(palette.danger)
            Text("One meal is not a failure.")
                .font(.system(size: 30, weight: .medium, design: .serif))
            Text("Do not skip the next meal, purge, overexercise, or punish yourself. Return to your normal pattern. A comfortable walk or short meditation can help you settle, but it does not need to erase what you ate.")
                .foregroundStyle(palette.secondaryText)
                .lineSpacing(5)
            Button("Take a gentle ten-minute walk") { dismiss() }
                .buttonStyle(.bordered)
            Button("Move on with my day") { dismiss() }
                .buttonStyle(.borderedProminent)
            Link("Eating-disorder support", destination: URL(string: "https://www.nationaleatingdisorders.org/get-help/")!)
                .font(.caption.weight(.semibold))
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(WithinBackground())
        .foregroundStyle(palette.text)
    }
}

private struct ProgressPhotoViewer: View {
    @EnvironmentObject private var app: AppModel
    @Environment(\.dismiss) private var dismiss
    let photoData: Data

    var body: some View {
        let palette = WithinPalette.palette(for: app.theme)
        NavigationStack {
            ZStack {
                WithinBackground()
                if let image = UIImage(data: photoData) {
                    ScrollView([.vertical, .horizontal]) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding(16)
                    }
                } else {
                    Text("This photo could not be opened.")
                        .foregroundStyle(palette.secondaryText)
                }
            }
            .navigationTitle("Private photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
