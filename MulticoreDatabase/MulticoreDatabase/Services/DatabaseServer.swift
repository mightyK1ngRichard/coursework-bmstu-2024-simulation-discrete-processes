//
//  DatabaseServer.swift
//  MulticoreDatabase
//
//  Created by Dmitriy Permyakov on 17.12.2024.
//

import Foundation

actor DatabaseServer {
    private(set) var queueLengths: [(date: String, Int)] = []
    private(set) var completedLog: [Agent] = []
    private(set) var activeReaders = 0
    private(set) var isWriting = false

    private var currentQueueLength = 0
    private let readerSemaphore: DispatchSemaphore
    private let writerSemaphore: DispatchSemaphore
    private var writerIsWaiting = false
    private var semaphorePausedReadAgents: Set<Agent> = []

    init(capacity: Int) {
        readerSemaphore = DispatchSemaphore(value: capacity)
        writerSemaphore = DispatchSemaphore(value: 1)
    }

    func reset() {
        queueLengths.removeAll()
        completedLog.removeAll()
        semaphorePausedReadAgents.removeAll()
    }

    func processRequest(agent: Agent) async {
        print(agent.startWork)
        let timeout = agent.operation == .read ? Constants.readTime : Constants.writeTime
        try? await Task.sleep(for: .seconds(timeout))
        print(agent.endWork(date: Date()))

        // Сохраняем успешный запрос
        var completedAgent = agent
        completedAgent.finishTime = Date()
        completedLog.append(completedAgent)
    }

    func addToQueue(agent: Agent) async {
        currentQueueLength += 1
        queueLengths.append((Date().currentTime, currentQueueLength))

        if agent.operation == .write {
            await handleWrite(agent: agent)
        } else {
            await handleRead(agent: agent)
        }

        currentQueueLength -= 1
        queueLengths.append((Date().currentTime, currentQueueLength))
    }

    private func handleWrite(agent: Agent) async {
        writerIsWaiting = true
        while activeReaders > 0 || !semaphorePausedReadAgents.isEmpty {
            print("[\(Date().currentTime)] ✍️ ⏸️ Агент #\(agent.id) ждёт записи")
            try? await Task.sleep(for: .seconds(1))
        }
        writerIsWaiting = false

        while writerSemaphore.wait(timeout: .now() + 1) == .timedOut {
            print("[\(Date().currentTime)] 👀 ⚙️ Агент #\(agent.id) не хватила потока. Ждёт освобождения")
            try? await Task.sleep(for: .seconds(Constants.pauseTime))
        }

        isWriting = true
        print("[\(Date().currentTime)] 🔐 Агент #\(agent.id) Блокирует для записи 🔐")

        await processRequest(agent: agent)

        isWriting = false
        writerSemaphore.signal()
        print("[\(Date().currentTime)] 🔓 Агент #\(agent.id) Разблокировал 🔓")
    }

    private func handleRead(agent: Agent) async {
        while isWriting || writerIsWaiting {
            print("[\(Date().currentTime)] 👀 ⏸️ Агент #\(agent.id) ждёт в очереди на чтение")
            try? await Task.sleep(for: .seconds(Constants.pauseTime))
        }

        while readerSemaphore.wait(timeout: .now() + 0.5) == .timedOut {
            semaphorePausedReadAgents.insert(agent)
            print("[\(Date().currentTime)] 👀 ⚙️ Агент #\(agent.id) не хватила потока. Ждёт освобождения")
            try? await Task.sleep(for: .seconds(Constants.pauseTime))
        }

        // Удаляем отложенную задачу если она там есть
        if let index = semaphorePausedReadAgents.firstIndex(where: { $0.id == agent.id }) {
            print("[\(Date().currentTime)] 👀 ⚙️ Агент #\(agent.id) УДАЛËНА из отложенных")
            semaphorePausedReadAgents.remove(at: index)
        }
        activeReaders += 1
        print("[\(Date().currentTime)] 👀 ➕ Агент #\(agent.id) захватил очередь. (всего: \(activeReaders))")

        await processRequest(agent: agent)
        activeReaders -= 1

        readerSemaphore.signal()
        print("[\(Date().currentTime)] 👀 ➖ Агент #\(agent.id) освободил очередь. (осталось: \(activeReaders))")
    }
}

// MARK: - Constants

enum Constants {
    /// Время симуляции (в секундах)
    static let simTime: TimeInterval = 30
    /// Средний интервал между запросами
    static let requestInterval = CGFloat.random(in: 0.5...1.5)
    /// Число ядер
    static let codesCapacity = 8
    /// Число пользователей
    static let numbersOfUsers = 50
    /// Время паузы между запросами
    static let pauseTime = 0.5
    /// Время выполнения процесса на чтение
    static let readTime = CGFloat.random(in: 1...2.5)
    /// Время выполнения процесса на запись
    static let writeTime = CGFloat.random(in: 3...5)
}
