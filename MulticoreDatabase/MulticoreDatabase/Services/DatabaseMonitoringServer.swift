//
//  DatabaseMonitoringServer.swift
//  MulticoreDatabase
//
//  Created by Dmitriy Permyakov on 17.12.2024.
//

import SwiftUI
import Foundation

final class DatabaseMonitoringServer: ObservableObject {
    @Published private(set) var readersCount = 0
    @Published private(set) var completedLog: [User] = []
    @Published private(set) var queueLengths: [(Date, Int)] = []
    private(set) var data: [String] = []

    private let queue = DispatchQueue(label: "queue", attributes: [.concurrent])
    private let counterQueue = DispatchQueue.main
    private let readSemaphore: DispatchSemaphore
    private var writeOperationWaiting = false

    init(codesCapacity: Int) {
        self.readSemaphore = DispatchSemaphore(value: codesCapacity)
    }

    func makeOperation(user: User) {
//        switch user.operation {
//        case let .select(index):
//            readOperation(user: user, index: index)
//        case let .write(newName):
//            writeOperation(user: user, newName: newName)
//        }
        switch user.operation {
        case .select:
            readOperation(user: user, index: 0)
        case .write:
            writeOperation(user: user, newName: "")
        }
    }

    private func writeOperation(user: User, newName: String) {
        writeOperationWaiting = true
        while readersCount > 0 {
            Thread.sleep(forTimeInterval: Constants.waitingForWriteTimeout)
        }
        writeOperationWaiting = false

        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            print("[\(Date().currentTime)]: 🔐 user #\(user.id)")

            // Имитируем длительность выполнения
            Thread.sleep(forTimeInterval: Constants.writeTimeout)
//            data.append(newName)
            print("[\(Date().currentTime)]: 🔓 user #\(user.id)")

            // Логируем пользователя
            counterQueue.sync {
                var tempUser = user
                tempUser.finishTime = Date()
                self.completedLog.append(tempUser)
            }
        }
    }

    private func readOperation(user: User, index: Int) {
        queue.async { [weak self] in
            guard let self else { return }
            readSemaphore.wait()
            incremantReadersCount(user: user)
            Thread.sleep(forTimeInterval: Constants.readTimeout)
//            if index > data.count {
//                let name = self.data[index]
//                print("[\(Date().currentTime)]: 👀 user #\(user.id) read name=\(name)")
//            }

            // Логируем пользователя
            counterQueue.sync {
                var tempUser = user
                tempUser.finishTime = Date()
                self.completedLog.append(tempUser)
            }

            readSemaphore.signal()
            decrementReadersCount(user: user)
        }
    }

    private func incremantReadersCount(user: User) {
        counterQueue.sync { [weak self] in
            guard let self else { return }
            readersCount += 1
            queueLengths.append((Date(), readersCount))
            print("[\(Date().currentTime)]: ✅ user #\(user.id) joined (users: \(readersCount))")
        }
    }

    private func decrementReadersCount(user: User) {
        counterQueue.sync { [weak self] in
            guard let self else { return }
            readersCount -= 1
            queueLengths.append((Date(), readersCount))
            print("[\(Date().currentTime)]: ❌ user #\(user.id) quit (users: \(self.readersCount))")
        }
    }
}
