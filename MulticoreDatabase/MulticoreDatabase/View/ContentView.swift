//
//  ContentView.swift
//  MulticoreDatabase
//
//  Created by Dmitriy Permyakov on 17.12.2024.
//
import SwiftUI
import Charts

struct ContentView: View {
    @State private var monitor = SimulationMonitor()

    var body: some View {
        ScrollView {
            Text("Мониторинг базы данных")
                .font(.title)
                .padding()

            // График длины очереди
            QueueLengthChart(queueLengths: monitor.queueLengths).overlay {
                if monitor.showLoader {
                    ProgressView()
                }
            }

            // График активности
            ActivityChart(activeReaders: monitor.activeReaders, isWriting: monitor.isWriting)

            // График завершенных запросов
            CompletedRequestsChart(completedLog: monitor.completedLog).overlay {
                if monitor.showLoader {
                    ProgressView()
                }
            }

            Button("Запустить симуляцию") {
                Task {
                    await monitor.runSimulation(numUsers: Constants.numbersOfUsers)
                }
            }
            .padding()
        }
        .padding()
        .background(.clear)
    }
}

// MARK: - Графики

#Preview {
    ContentView()
}
