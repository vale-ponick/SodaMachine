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

