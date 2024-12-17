//
//  DatabaseMonitoringView.swift
//  MulticoreDatabase
//
//  Created by Dmitriy Permyakov on 17.12.2024.
//

import SwiftUI
import Charts

enum Constants {
    /// Скорость такста
    static let tact = 22.4
    /// Время выполнения запроса на чтение
    static let readTimeout = CGFloat.random(in: (1 / tact)...(2 / tact))
    /// Время выполнения запроса на запись
    static let writeTimeout = CGFloat.random(in: (5 / tact)...(8 / tact))
    /// Количество запросов
    static let numUsers = 1000
    /// Таймаут ожидания начала чтения
    static let waitingForWriteTimeout = 1 / (tact * 2000)
    /// Число ядер
    static let codesCapacity = 8
}

struct DatabaseMonitoringView: View {
    @StateObject private var monitor = DatabaseMonitoringServer(codesCapacity: Constants.codesCapacity)

    var body: some View {
        ScrollView {
            Text("Мониторинг базы данных")
                .font(.title)
                .padding()

            HStack {
                VStack(alignment: .leading) {
                    Text("Число запросов: \(monitor.completedLog.count) из \(Constants.numUsers)")
                    Text("Скорость такта: \(Constants.tact)")
                    Text("Число ядер: \(Constants.codesCapacity)")
                }

                Button("Запустить симуляцию") {
                    runSimulation(numUsers: Constants.numUsers)
                }
                .padding()
            }

            // График длины очереди
            QueueLengthChart(queueLengths: monitor.queueLengths)

            // График активности
            ActivityChart(activeReaders: monitor.readersCount)

            // График завершенных запросов
            CompletedRequestsChart(completedLog: monitor.completedLog)
        }
        .padding()
        .background(.clear)
    }

    func runSimulation(numUsers: Int) {
        for userID in 0..<numUsers {
            DispatchQueue.global().async {
                let operation: SQLOperation = Int.random(in: 1...8) == 5 ? .write : .select
                let user = User(id: userID, operation: operation)
                monitor.makeOperation(user: user)
            }
        }
    }
}

// MARK: - Графики

#Preview {
    DatabaseMonitoringView()
}
