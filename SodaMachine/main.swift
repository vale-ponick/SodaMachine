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

// 2. STRUCTS WITH FAILABLE INIT & ENCAPSULATION:
struct TeaCup {
    private(set) var volume: Int // Защита от прямого изменения извне
    init? (volume: Int = 0) { // Кастомный инит, который не пропустит плохой объем при создании
        guard volume >= 0 && volume <= 200 else {
            return nil
        }
        self.volume = volume
    }
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
// TESTS:
let rawTray: [TeaCup?] = [ // 1. Создай опциональный массив
    TeaCup(volume: 0),
    TeaCup(volume: 90),
    TeaCup(volume: 200)
]
let tray: [TeaCup] = rawTray.compactMap { $0 } // Чистим его от nil

let order: [Ingredient] = [
    Honey.fresh,          // для чашки № 1 (0 мл)
    Confiture.strawberry, // для чашки № 2 (90 мл)
    Honey.flower          // для чашки № 3 (200 мл)
]
print("--- ТЕСТ МАССИВА ЧАШЕК ---")
// Исправлено: теперь цикл идет строго по чистому массиву `tray`
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
        print("Tray \(index): ❌ Unknown error: \(error)")
    }
}
// 1. Создаем массив замыканий (функциональный конвейер)
// Тип: массив функций, которые принимают TeaCup и возвращают новую TeaCup (или кидают ошибку)
let teaPipeline: [(TeaCup) throws -> TeaCup] = [
    { var cup = $0; try cup.addIngredient(type: Honey.fresh); return cup },       // Шаг 1: +42 мл мёда
    { var cup = $0; try cup.addIngredient(type: Confiture.strawberry); return cup }, // Шаг 2: +42 мл клубники
    { var cup = $0; try cup.addIngredient(type: Honey.buckwheat); return cup }    // Шаг 3: +33 мл гречишного мёда
]
// 2. ФУНКЦИОНАЛЬНЫЙ КОНВЕЙЕР
let teaCupPipeline: [(TeaCup) throws -> TeaCup] = [
    { var cup = $0; try cup.addIngredient(type: Honey.fresh); return cup },
    { var cup = $0; try cup.addIngredient(type: Confiture.strawberry); return cup },
    { var cup = $0; try cup.addIngredient(type: Honey.buckwheat); return cup }
]
print("\n--- ЗАПУСК ФУНКЦИОНАЛЬНОГО КОНВЕЙЕРА ---")

// 2. Начальное состояние: чистая чашка (volume: 0) и флаг остановки false
guard let initialCup = TeaCup(volume: 0) else {
    fatalError("Cannot create initial cup")
}
let initialTuple = (cup: initialCup, isFinished: false)

// 3. Запускаем свертку конвейера
let finalPipelineResult = teaPipeline.reduce(initialTuple) { state, nextStep in
    guard !state.isFinished else { return state }
    
    do {
        let updatedCup = try nextStep(state.cup)  // ← вызываем шаг!
        
        if updatedCup.isFull {
            print("🚨 Чашка наполнилась до максимума!")
            return (cup: updatedCup, isFinished: true)
        }
        
        print("➡️ Шаг выполнен. Объём: \(updatedCup.volume) мл.")
        return (cup: updatedCup, isFinished: false)
        
    } catch TeaCupError.cupOverflow(let extra) {
        print("🚨 Переполнение! \(extra) мл не поместилось.")
        return (cup: state.cup, isFinished: true)
    } catch {
        print("🚨 Ошибка: \(error)")
        return (cup: state.cup, isFinished: true)
    }
}

// 4. Проверяем итоговый результат
print("✅ Итоговый объем чашки на конвейере: \(finalPipelineResult.cup.volume) мл.")
print("✅ Итоговый статус чашки: \(finalPipelineResult.cup.status)")
/*
 --- ТЕСТ МАССИВА ЧАШЕК ---
 Tray 0: ✅ New volume: 42 ml. Added: 🐝 fresh honey
 Tray 1: ✅ New volume: 132 ml. Added: 🍓 strawberry
 Tray 2: ❌ Overflow! 21 ml for 🌸 flower honey not fitted. Status of cup: Full cup.

 --- ЗАПУСК ФУНКЦИОНАЛЬНОГО КОНВЕЙЕРА ---
 ➡️ Шаг выполнен. Объём: 42 мл.
 ➡️ Шаг выполнен. Объём: 84 мл.
 ➡️ Шаг выполнен. Объём: 117 мл.
 ✅ Итоговый объем чашки на конвейере: 117 мл.
 ✅ Итоговый статус чашки: In Progress
 */

// MARK: - Test. 'Урок зельеварения у Слизнорта'. 5 студентов варят «Напиток живой смерти». Цель — прозрачное зелье (победа).

//full code: (SWIFT 6.4, STATE MACHINE + .finish)

// MARK: - Базовые перечисления
enum Approach {
    case officialBook, halfBloodPrince, hastilyChop
}

enum Step {
    case boilWater, cutValerian, pressBeans, stir, finish   // 🆕 .finish
}

enum PotionColor: String {
    case clear, boiling, currant, lilac, pink, transparent
    case ruinedMurky = "ruined murky"
    case licorice = "wet licorice"
    case darkBlue = "deep blue"
}

enum StepError: Error {
    case cutBeans(color: PotionColor)
    case stirClockwise(color: PotionColor)
    case ruinedByChop(color: PotionColor)
}

struct PotionResult {
    let color: PotionColor
    let isWinner: Bool
    
    var slughornAction: String {
        isWinner
            ? "💥 «Professor Slughorn: 'Good Lord, it’s clear you’ve inherited your mother’s talent, she was a dab hand at Potions, Lily was! Here you are, then, here you are – one bottle of Felix Felicis, as promised, and use it well!'"
            : "🧙 Professor Slughorn peered into the cauldron and moved on without a word."
    }
}

// MARK: - Состояния конечного автомата
enum CauldronState {
    case empty
    case waterBoiling
    case valerianAdded(color: PotionColor)
    case beansPressed(color: PotionColor)
    case stirred(color: PotionColor)              // 🆕 промежуточное
    case successfullyBrewed(PotionResult)
    case failed(StepError)
}

// MARK: - Управляющий объект (State Machine)
final class Cauldron {
    private(set) var state: CauldronState = .empty
    let studentName: String
    
    init(studentName: String) {
        self.studentName = studentName
    }
    
    /// Принимает ОДНО действие и переводит систему в СЛЕДУЮЩЕЕ состояние
    func apply(step: Step, approach: Approach) {
        switch state {
        case .empty:
            guard step == .boilWater else { return }
            state = .waterBoiling
            print("  [Cauldron \(studentName)]: 🍲 The water is boiling.")

            
        case .waterBoiling:
            guard step == .cutValerian else { return }
            if approach == .hastilyChop {
                state = .failed(.ruinedByChop(color: .ruinedMurky))
            } else {
                state = .valerianAdded(color: .currant)
                print("  [Cauldron \(studentName)]: 🍲 Valerian roots added. The potion turned dark currant.")
            }
            
        case .valerianAdded:
            guard step == .pressBeans else { return }
            
            if studentName == "Ron" {
                state = .failed(.cutBeans(color: .licorice))
                return
            }
            
            if approach == .halfBloodPrince {
                state = .beansPressed(color: .lilac)
                print("  [Cauldron \(studentName)]: 🍲 Sopophorous bean juice added. The potion turned lilac.")
                if studentName == "Harry" {
                    print("  [Harry]: \"Hermione, you should crush the bean with the silver dagger, not cut it!\"")
                }
            } else {
                state = .beansPressed(color: .lilac)
                print("  [Cauldron \(studentName)]: 🍲 Sopophorous bean juice added. The potion turned lilac.")
                if studentName == "Hermione" {
                    print("  [Hermione]: \"The instructions in the book say to slice it!\"")
                }
            }
            
        case .beansPressed:
            guard step == .stir else { return }
            if approach == .halfBloodPrince {
                state = .stirred(color: .pink)            // ← промежуточный
                print("  [Cauldron \(studentName)]: 🍲 The potion turned light pink.")

            } else {
                let finalColor: PotionColor = (studentName == "Hermione") ? .lilac : .darkBlue
                state = .failed(.stirClockwise(color: finalColor))
            }
            
        case .stirred:                                    // 🆕 финал
            guard step == .finish else { return }
            let result = PotionResult(color: .transparent, isWinner: true)
            state = .successfullyBrewed(result)
            print("  [Cauldron \(studentName)]: 🍲 The potion turned completely clear!")
            
        case .successfullyBrewed, .failed:
            break   // после финала — игнор
        }
    }
    
    /// Финальная оценка состояния котла для Слизнорта
    func checkResult() -> String {
        switch state {
        case .successfullyBrewed(let result):
            return "✅ \(result.color.rawValue)\n   \(result.slughornAction)"
            
        case .failed(let error):
            let details = switch error {
            case .cutBeans(let color):     "❌ cutBeans — \(color.rawValue)"
            case .stirClockwise(let color): "❌ stirClockwise — \(color.rawValue)"
            case .ruinedByChop(let color):  "❌ ruinedByChop — \(color.rawValue)"
            }
            return "\(details)\n 🧙 Professor Slughorn peered into the cauldron and moved on without a word."
            
        case .stirred(let color):
            return "❌ Professor Slughorn peered into the cauldron and moved on without a word: (\(color.rawValue)."
            
        default:
            return "❌ Professor Slughorn peered into the cauldron and moved on without a word."
        }
    }
}

// MARK: - Симуляция урока
struct Student {
    let name: String
    let timeline: [(step: Step, approach: Approach)]
}

let hogwartsClass = [
    Student(name: "Harry", timeline: [
        (.boilWater, .halfBloodPrince),
        (.cutValerian, .halfBloodPrince),
        (.pressBeans, .halfBloodPrince),
        (.stir, .halfBloodPrince),
        (.finish, .halfBloodPrince)          // 🆕
    ]),
    Student(name: "Hermione", timeline: [
        (.boilWater, .officialBook),
        (.cutValerian, .officialBook),
        (.pressBeans, .officialBook),
        (.stir, .officialBook),
        (.finish, .officialBook)              // 🆕
    ]),
    Student(name: "Ron", timeline: [
        (.boilWater, .officialBook),
        (.cutValerian, .officialBook),
        (.pressBeans, .officialBook),
        (.stir, .officialBook),
        (.finish, .officialBook)              // 🆕
    ]),
    Student(name: "Malfoy", timeline: [
        (.boilWater, .officialBook),
        (.cutValerian, .hastilyChop),
        (.pressBeans, .officialBook),
        (.stir, .officialBook),
        (.finish, .officialBook)              // 🆕
    ]),
    Student(name: "Ernie", timeline: [
        (.boilWater, .officialBook),
        (.cutValerian, .officialBook),
        (.pressBeans, .officialBook),
        (.stir, .officialBook),
        (.finish, .officialBook)              // 🆕
    ])
]

for student in hogwartsClass {
    print("--- Student \(student.name) starts brewing ---")
    let cauldron = Cauldron(studentName: student.name)
    
    for action in student.timeline {
        cauldron.apply(step: action.step, approach: action.approach)
    }
    
    print("Professor Slughorn's inspection:")
    print(cauldron.checkResult())
    print(" ------ \n")
}
/*
 --- Student Harry starts brewing ---
   [Cauldron Harry]: 🍲 The water is boiling.
   [Cauldron Harry]: 🍲 Valerian roots added. The potion turned dark currant.
   [Cauldron Harry]: 🍲 Sopophorous bean juice added. The potion turned lilac.
   [Harry]: "Hermione, you should crush the bean with the silver dagger, not cut it!"
   [Cauldron Harry]: 🍲 The potion turned light pink.
   [Cauldron Harry]: 🍲 The potion turned completely clear!
 Professor Slughorn's inspection:
 ✅ transparent
    💥 «Professor Slughorn: 'Good Lord, it’s clear you’ve inherited your mother’s talent, she was a dab hand at Potions, Lily was! Here you are, then, here you are – one bottle of Felix Felicis, as promised, and use it well!'
  ------

 --- Student Hermione starts brewing ---
   [Cauldron Hermione]: 🍲 The water is boiling.
   [Cauldron Hermione]: 🍲 Valerian roots added. The potion turned dark currant.
   [Cauldron Hermione]: 🍲 Sopophorous bean juice added. The potion turned lilac.
   [Hermione]: "The instructions in the book say to slice it!"
 Professor Slughorn's inspection:
 ❌ stirClockwise — lilac
  🧙 Professor Slughorn peered into the cauldron and moved on without a word.
  ------

 --- Student Ron starts brewing ---
   [Cauldron Ron]: 🍲 The water is boiling.
   [Cauldron Ron]: 🍲 Valerian roots added. The potion turned dark currant.
 Professor Slughorn's inspection:
 ❌ cutBeans — wet licorice
  🧙 Professor Slughorn peered into the cauldron and moved on without a word.
  ------

 --- Student Malfoy starts brewing ---
   [Cauldron Malfoy]: 🍲 The water is boiling.
 Professor Slughorn's inspection:
 ❌ ruinedByChop — ruined murky
  🧙 Professor Slughorn peered into the cauldron and moved on without a word.
  ------

 --- Student Ernie starts brewing ---
   [Cauldron Ernie]: 🍲 The water is boiling.
   [Cauldron Ernie]: 🍲 Valerian roots added. The potion turned dark currant.
   [Cauldron Ernie]: 🍲 Sopophorous bean juice added. The potion turned lilac.
 Professor Slughorn's inspection:
 ❌ stirClockwise — deep blue
  🧙 Professor Slughorn peered into the cauldron and moved on without a word.
  ------ 
 */
