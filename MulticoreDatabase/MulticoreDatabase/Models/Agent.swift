//
//  Agent.swift
//  MulticoreDatabase
//
//  Created by Dmitriy Permyakov on 17.12.2024.
//

import Foundation

struct Agent: Hashable, Equatable {
    let id: String
    let operation: OperationKind
    let arrivalTime: Date
    var finishTime: Date?

    var startWork: String {
        switch operation {
        case .read:
            return "[\(arrivalTime.currentTime)] 👀 ➡️ Агент #\(id) начал чтение"
        case .write:
            return "[\(arrivalTime.currentTime)] ✍️ ➡️ Агент #\(id) начал запись"
        }
    }

    func endWork(date: Date) -> String {
        switch operation {
        case .read:
            return "[\(date.currentTime)] 👀 ⬅️ Агент #\(id) закончил чтение"
        case .write:
            return "[\(date.currentTime)] ✍️ ⬅️ Агент #\(id) закончил запись"
        }
    }
}

extension Agent {
    enum OperationKind {
        case read
        case write
    }
}

extension Agent {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Agent, rhs: Agent) -> Bool {
        lhs.id == rhs.id
    }
}
