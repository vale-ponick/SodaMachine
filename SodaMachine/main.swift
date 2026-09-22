//
//  main.swift
//  SodaMachine
//
//  Created by Валерия Пономарева on 21.09.2026.
//

import Foundation

// MARK: - 🥤 'A soda machine that dispenses syrup': there's a base cup size and two buttons.
/**
Step 1: Create an Enum
Create an enum Syrup with type Int (Raw Value): case cherry = 30 case vanilla = 20
Step 2: Create an Error
Create an enum SyrupError: Error: case emptyTank (out of syrup)
Step 3: Write a Function
Write a function pourSyrup(currentVolume: Int, type: Syrup?) throws -> Int.
If type is nil (no syrup selected), the function should throw the error SyrupError.emptyTank.
If syrup is selected, the function simply adds its rawValue to currentVolume and returns the new volume.
Step 4: Test it out
Call the function inside the do-catch block, passing in an initial volume of 100 and syrup .cherry.
Print the result to the console. Call the function again, passing nil instead of syrup, to test how the catch block works.
*/
enum Syrup: Int {
    case cherry = 30
    case vanilla = 20
}
enum SyrupError: Error {
    case emptyTank // out of syrop
}
func pourSyrup(currentVolume: Int, type: Syrup?) throws -> Int {
    guard let type else {
        throw SyrupError.emptyTank
    }
    
return currentVolume + type.rawValue
}
// var. 1
do {
    let result = try pourSyrup(currentVolume: 100, type: .cherry)
    print("✅ Success! Volume: \(result) ml.") // ✅ Success! Volume: 130 ml.
} catch SyrupError.emptyTank {
    print("❌ Problems with syrup.")
} catch {
    print("❌ Unknown error: \(error)")
}
// var. 2
do {
    let result = try pourSyrup(currentVolume: 100, type: nil)
    print("✅ Success! Volume: \(result) ml.")
} catch SyrupError.emptyTank {
    print("❌ Problems with syrup.") // ❌ Problems with syrup: Tank is empty
} catch {
    print("❌ Unknown error: \(error)")
}

// MARK: - Task 2. '☕️ 🍓🫐 Cap of tea with jam': struct + computed property + error handling & associated values

enum Jam: Int {
    case strawberry = 40
    case raspberry = 35
    
    var name: String {
        switch self {
        case .strawberry: return "🍓 strawberry"
        case .raspberry: return "🫐 raspberry"
        }
    }
}

enum JamError: Error {
    case emptyTank
    case cupOverflow(notFittedVolume: Int)
}

struct Cup {
    var volume: Int = 0 // Хранимое свойство
    var isFull: Bool { volume >= 150 } // Вычисляемые свойства (Computed Properties)
    var remainingSpace: Int { 150 - volume }
    var status: String { // Новое вычисляемое свойство со сложной логикой (switch)
          switch volume {
          case 0:
              return "Empty"
          case 1..<150:
              return "In Progress"
          case 150...:
              return "Full"
          default:
             return "Unknown"
          }
      }
    
    mutating func addJam(type: Jam?) throws {  // Метод, который меняет чашку изнутри
        guard let type else { throw JamError.emptyTank } // Check: choose jam?
        guard remainingSpace >= type.rawValue else { // Smart check: if  space < volume of jam, cancel
            let extraVolume = type.rawValue - remainingSpace
            throw JamError.cupOverflow(notFittedVolume: extraVolume)
        }
        volume += type.rawValue // If OK -> + jam in cap
    }
}

// --- TESTS: ---
let jams: [Jam] = [.strawberry, .raspberry]
for jam in jams {
    var cup = Cup()
    do {
        try cup.addJam(type: jam)
        print("✅ \(cup.volume) ml with \(jam.name) jam.")
    } catch {
        print("❌ \(jam.name): \(error)")
    }
}
var myCup = Cup()
print("Free volume in cap: \(myCup.remainingSpace) ml.") // Free volume in cap: 150 ml.
print("Initial cup status: \(myCup.status)") // Initial cup status: Empty


do {
    let jamType: Jam = .strawberry
    print("Trying to add \(jamType.name) jam (\(jamType.rawValue) ml)...")
    try myCup.addJam(type: jamType)
    print("✅ Success! New volume: \(myCup.volume) ml with \(jamType.name) jam.")
} catch JamError.cupOverflow(let extra) {
    print("❌ Overflow! \(extra) ml. not fitted in cap!")
} catch {
    print("❌ Another error: \(error)")
}

print("Final cup status: \(myCup.status)")
print(" --- ")
var fullCap = Cup(volume: 150)
print("Free volume in cap: \(fullCap.remainingSpace) ml.") // Free volume in cap: 150 ml.
print("Initial cup status: \(fullCap.status)")

do {
    let _: Jam = .raspberry
    try fullCap.addJam(type: .raspberry)  // 140 + 40 = 180 > 150
} catch JamError.cupOverflow(let extra) {
    print("❌ Overflow! \(extra) ml. not fitted!")  // 30 ml
} catch {
    print("❌ Another error: \(error)")
}
    
// Проверяем статус в самом конце
print("Final cup status: \(fullCap.status)")

    /*
     ✅ 40 ml with 🍓 strawberry jam.
     ✅ 35 ml with 🫐 raspberry jam.
     Free volume in cap: 150 ml.
     Initial cup status: Empty
     Trying to add 🍓 strawberry jam (40 ml)...
     ✅ Success! New volume: 40 ml with 🍓 strawberry jam.
     Final cup status: In Progress
      ---
     Free volume in cap: 0 ml.
     Initial cup status: Full
     ❌ Overflow! 35 ml. not fitted!
     Final cup status: Full */

// MARK: - Test 3. '☕️ 🍯 🐝 Cap of tea with honey': struct + computed property + error handling & raw values + extension + tray
protocol Ingredient { // Это договор: «Любой, кто хочет быть Ингредиентом, обязан иметь текстовое имя name и числовой объём rawValue».
    var name: String { get }
    var rawValue: Int { get }
}

// 1. ENUMS:
enum Honey: Int, Ingredient { // enum with assosiated values + computed property
    case fresh = 42
    case linden = 38
    case buckwheat = 33
    case flower = 21
    case heather = 27
    
    var name: String {
        switch self {
        case .fresh: return "🐝 fresh honey"
        case .linden: return "🌳 linden honey" // липовый
        case .buckwheat: return "🌼 buckwheat honey" // гречишный
        case .flower: return "🌸 flower honey"
        case .heather: return "🪻 heather honey" // вересковый
        }
    }
}
enum Confiture: Int, Ingredient {
    case strawberry = 42
    case raspberry = 36
        
    var name: String {
        switch self {
        case .strawberry: return "🍓 strawberry"
        case .raspberry: return "🫐 raspberry"
        }
    }
}

enum TeaCupError: Error {
    case emptyTank
    case cupOverflow(notFittedVolume: Int)
}

// 2. STRUCTS:
struct TeaCup {
    private(set) var volume: Int = 0 // инкапсуляция => «Но читать её (get) всё ещё можно без ограничений».
}

// 3. EXTENSIONS:
extension TeaCup {
    var isFull: Bool {
        volume >= 200
    }
    var remainingSpace: Int {
        200 - volume
    }
    var status: String {
        switch volume {
        case 0:
            return "Empty"
        case 1..<200:
            return "In Progress"
        case 200...:
            return "Full cup"
        default:
            return "Unknown"
        }
    }
    mutating func addIngredient(type: Ingredient?) throws {
        guard let type else {
            throw TeaCupError.emptyTank
        }
        guard remainingSpace >= type.rawValue else {
            let extraVolume = type.rawValue - remainingSpace
            throw TeaCupError.cupOverflow(notFittedVolume: extraVolume)
        }
        volume += type.rawValue
    }
}
let tray: [TeaCup] = [
    TeaCup(volume: 0),
    TeaCup(volume: 90),
    TeaCup(volume: 200)
]
let order: [Ingredient] = [
    Honey.fresh, // для чашки № 1 (0 мл)
    Confiture.strawberry, // для чашки № 2 (90 мл)
    Honey.flower // для чашки № 3 (200 мл)
]
for (index, teaCup) in tray.enumerated() {
    var mutableCup = teaCup // copy for mutating volume
    let ingredient = order[index] // достань ингредиент, закрепленный за чашкой
    do {
        try mutableCup.addIngredient(type: ingredient) // наливаем УНИВЕРСальный ингредиент
        print("Tray \(index): ✅ New volume: \(mutableCup.volume) ml. Added: \(ingredient.name)")
    } catch TeaCupError.emptyTank {
        print("Tray \(index): ❌ Ingredient not found.")
    } catch TeaCupError.cupOverflow(let extra) {
        print("Tray \(index): ❌ Overflow! \(extra) ml for \(ingredient.name) not fitted. Status of cup: \(mutableCup.status).")
    } catch {
        print("Tray \(index): ❌ Anknown error: \(error)")
    }
}
// 1. Создаем массив замыканий (функциональный конвейер)
// Тип: массив функций, которые принимают TeaCup и возвращают новую TeaCup (или кидают ошибку)
let teaPipeline: [(TeaCup) throws -> TeaCup] = [
    { var cup = $0; try cup.addIngredient(type: Honey.fresh); return cup },       // Шаг 1: +42 мл мёда
    { var cup = $0; try cup.addIngredient(type: Confiture.strawberry); return cup }, // Шаг 2: +42 мл клубники
    { var cup = $0; try cup.addIngredient(type: Honey.buckwheat); return cup }    // Шаг 3: +33 мл гречишного мёда
]

print("\n--- ЗАПУСК ФУНКЦИОНАЛЬНОГО КОНВЕЙЕРА ---")

// 2. Начальное состояние: чистая чашка (volume: 0) и флаг остановки false
let initialTuple = (cup: TeaCup(), isFinished: false)

// 3. Запускаем свертку конвейера
let finalPipelineResult = teaPipeline.reduce(initialTuple) { state, nextStep in
    // Если на прошлых шагах конвейер уже был остановлен, просто передаем состояние дальше (аналог break)
    guard !state.isFinished else { return state }
    
    do {
        // Пытаемся применить следующий шаг конвейера к чашке из предыдущего состояния
        let updatedCup = try nextStep(state.cup)
        
        // Дополнительная проверка на лимит, если нужно зафиксировать статус
        if updatedCup.isFull {
            print("🚨 Чашка наполнилась до максимума! Прекращаем добавление топпингов.")
            return (cup: updatedCup, isFinished: true)
        }
        
        print("➡️ Шаг конвейера выполнен успешно. Текущий объем: \(updatedCup.volume) мл.")
        return (cup: updatedCup, isFinished: false)
        
    } catch TeaCupError.cupOverflow(let extra) {
        // Умный откат: если шаг вызвал переполнение, мы возвращаем ПРЕДЫДУЩУЮ чашку (state.cup)
        // и выставляем флаг завершения конвейера (isFinished: true)
        print("🚨 Конвейер заблокировал переполнение! Не поместилось \(extra) мл. Последний ингредиент отменен.")
        return (cup: state.cup, isFinished: true)
    } catch {
        print("🚨 Непредвиденная ошибка на конвейере: \(error)")
        return (cup: state.cup, isFinished: true)
    }
}

// 4. Проверяем итоговый результат
print("✅ Итоговый объем чашки на конвейере: \(finalPipelineResult.cup.volume) мл.")
print("✅ Итоговый статус чашки: \(finalPipelineResult.cup.status)")
/*
 Tray 0: ✅ New volume: 42 ml. Added: 🐝 fresh honey
 Tray 1: ✅ New volume: 132 ml. Added: 🍓 strawberry
 Tray 2: ❌ Overflow! 21 ml for 🌸 flower honey not fitted. Status of cup: Full cup.
 --- ЗАПУСК ФУНКЦИОНАЛЬНОГО КОНВЕЙЕРА ---
 ➡️ Шаг конвейера выполнен успешно. Текущий объем: 42 мл.
 ➡️ Шаг конвейера выполнен успешно. Текущий объем: 84 мл.
 ➡️ Шаг конвейера выполнен успешно. Текущий объем: 117 мл.
 ✅ Итоговый объем чашки на конвейере: 117 мл.
 ✅ Итоговый статус чашки: In Progress
 */
