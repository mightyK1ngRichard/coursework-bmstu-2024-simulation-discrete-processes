//
//  SimulationMonitor.swift
//  MulticoreDatabase
//
//  Created by Dmitriy Permyakov on 17.12.2024.
//

import Foundation
import Observation

@Observable
final class SimulationMonitor {
    private(set) var queueLengths: [(date: String, Int)] = []
    private(set) var activeReaders = 0
    private(set) var isWriting = false
    private(set) var completedLog: [Agent] = []
    private(set) var showLoader = false

    @ObservationIgnored
    private var task: Task<Void, Never>?
    @ObservationIgnored
    private var server = DatabaseServer(capacity: Constants.codesCapacity)

    func runSimulation(numUsers: Int) async {
        guard task == nil else { return }
        await reset()

        // Мониторинг активности читателей и писателей
        task = Task {
            while true {
                let activeReaders = await server.activeReaders
                let isWriting = await server.isWriting
                await MainActor.run {
                    self.activeReaders = activeReaders
                    self.isWriting = isWriting
                }
                try? await Task.sleep(for: .seconds(0.2))
            }
        }

        // Генерация запросов
        await generateRequests(numUsers: numUsers)

        // Завершение симуляции
        await MainActor.run {
            showLoader = true
        }
        
        try? await Task.sleep(nanoseconds: UInt64(Constants.simTime) * 1_000_000_000)
        print("Симуляция завершена.")
        let queueLengths = await server.queueLengths
        let completedLog = await server.completedLog
        await MainActor.run {
            self.queueLengths = queueLengths
            self.completedLog = completedLog
            showLoader = false
        }
        task?.cancel()
        task = nil
    }
}

// MARK: - Helpers

private extension SimulationMonitor {
    func generateRequests(numUsers: Int) async {
        for requestId in 0..<numUsers {
            try? await Task.sleep(for: .seconds(Constants.requestInterval))
            Task {
                let agent = Agent(
                    id: String(requestId),
                    operation: requestId % 6 == 0 ? .write : .read,
                    arrivalTime: Date()
                )
                await server.addToQueue(agent: agent)
            }
        }
    }

    func reset() async {
        queueLengths = []
        completedLog = []
        activeReaders = 0
        await server.reset()
    }

    /// Функция для генерации случайного значения из треугольного распределения
    func triangularDistribution(min: Double, mode: Double, max: Double) -> Double {
        let u = Double.random(in: 0...1) // случайное число из [0, 1]

        if u < (mode - min) / (max - min) {
            return min + sqrt(u * (max - min) * (mode - min))
        } else {
            return max - sqrt((1 - u) * (max - min) * (max - mode))
        }
    }

    func triangularGenerateRequests(numUsers: Int) async {
        let minInterval = 0.5
        let maxInterval = 3.0
        let modeInterval = 1.0

        for requestId in 0..<numUsers {
            // Генерация случайного времени на основе треугольного распределения
            let delay = triangularDistribution(min: minInterval, mode: modeInterval, max: maxInterval)
            try? await Task.sleep(for: .seconds(delay))

            Task {
                let agent = Agent(
                    id: String(requestId),
                    operation: requestId % 6 == 0 ? .write : .read,
                    arrivalTime: Date()
                )
                await server.addToQueue(agent: agent)
            }
        }
    }
}
