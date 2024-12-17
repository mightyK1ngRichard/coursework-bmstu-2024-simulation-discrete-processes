//
//  User.swift
//  MulticoreDatabase
//
//  Created by Dmitriy Permyakov on 18.12.2024.
//

import Foundation

struct User {
    let id: Int
    let operation: SQLOperation
    let arrivalTime: Date
    var finishTime: Date?

    init(
        id: Int,
        operation: SQLOperation,
        arrivalTime: Date = Date(),
        finishTime: Date? = nil
    ) {
        self.id = id
        self.operation = operation
        self.finishTime = finishTime
        self.arrivalTime = arrivalTime
    }
}

enum SQLOperation {
    case select
    case write
//    case select(Int)
//    case write(String)
}
