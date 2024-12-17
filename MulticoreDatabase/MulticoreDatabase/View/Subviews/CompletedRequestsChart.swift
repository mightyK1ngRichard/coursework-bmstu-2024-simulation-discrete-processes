//
//  CompletedRequestsChart.swift
//  MulticoreDatabase
//
//  Created by Dmitriy Permyakov on 17.12.2024.
//

import SwiftUI
import Charts

struct CompletedRequestsChart: View {
    let completedLog: [User]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Таймлайн запросов")
                .font(.headline)
                .padding()

            ScrollView(.horizontal) {
                Chart {
                    ForEach(completedLog, id: \.id) { agent in
                        PointMark(
                            x: .value("Время завершения", agent.finishTime!),
                            y: .value("Номер запроса", agent.id)
                        )
                        .foregroundStyle(agent.operation == .write ? .red : .blue)
                        .symbol(agent.operation == .write ? .circle : .square)
                    }
                }
                .frame(width: CGFloat(completedLog.count) * 100)
                .padding()
            }
            .frame(minHeight: 300)

            // График для отображения длительности операций
            Text("Длительность запросов")
                .font(.headline)
                .padding(.top)

            ScrollView(.horizontal) {
                Chart {
                    ForEach(completedLog, id: \.id) { agent in
                        if let finishTime = agent.finishTime {
                            let durationMilliseconds = finishTime.timeIntervalSince(agent.arrivalTime) * 1_000
                            BarMark(
                                x: .value("ID запроса", agent.id),
                                y: .value("Длительность (мс)", durationMilliseconds)
                            )
                            .foregroundStyle(
                                agent.operation == .write
                                ? .red.opacity(0.6)
                                : .blue.opacity(0.6)
                            )
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text("\(Int(doubleValue)) мс")
                            }
                        }
                    }
                }
                .frame(width: CGFloat(completedLog.count) * 40)
                .frame(minHeight: 300)
                .padding()
            }
        }
        .frame(minHeight: 300)
        .background(.background, in: .rect(cornerRadius: 10))
    }
}

// MARK: - Preview

#Preview {
    // Данные для превью
    let calendar = Calendar.current
    let baseDate = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!
    let testData = [
        User(
            id: 1,
            operation: .select,
            arrivalTime: baseDate,
            finishTime: baseDate.addingTimeInterval(0.002) // 2 мс
        ),
        User(
            id: 2,
            operation: .write,
            arrivalTime: baseDate.addingTimeInterval(2), // Через 2 секунды
            finishTime: baseDate.addingTimeInterval(2.01) // 10 мс
        ),
        User(
            id: 3,
            operation: .select,
            arrivalTime: baseDate.addingTimeInterval(4), // Через 4 секунды
            finishTime: baseDate.addingTimeInterval(4.005) // 5 мс
        )
    ]

    return ScrollView {
        CompletedRequestsChart(completedLog: testData)
            .padding()
    }
}
