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
