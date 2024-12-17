//
//  CompletedRequestsChart.swift
//  MulticoreDatabase
//
//  Created by Dmitriy Permyakov on 17.12.2024.
//

import SwiftUI
import Charts

struct CompletedRequestsChart: View {
    var completedLog: [Agent]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Завершенные запросы")
                .font(.headline)
                .padding()

            ScrollView(.horizontal) {
                Chart {
                    ForEach(completedLog, id: \.id) { agent in
                        PointMark(
                            x: .value("Время завершения", agent.finishTime!),
                            y: .value("Номер запроса", Int(agent.id) ?? 0)
                        )
                        .foregroundStyle(agent.operation == .write ? .red : .blue)
                        .symbol(agent.operation == .write ? .circle : .square)
                    }
                }
                .frame(width: CGFloat(completedLog.count) * 10)
                .padding()
            }
            .frame(minHeight: 300)

            ScrollView(.horizontal) {
                Chart {
                    ForEach(completedLog, id: \.id) { agent in
                        if let finishTime = agent.finishTime {
                            let duration = finishTime.timeIntervalSince(agent.arrivalTime)
                            BarMark(
                                x: .value("Номер запроса", agent.id),
                                y: .value("Длительность (сек)", duration)
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
                        AxisValueLabel()
                    }
                }
                .frame(minHeight: 300)
                .frame(width: CGFloat(completedLog.count) * 25)
                .padding()
            }
        }
        .frame(minHeight: 300)
        .background(.background, in: .rect(cornerRadius: 10))
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        CompletedRequestsChart(
            completedLog: (1...100).compactMap {
                let calendar = Calendar.current
                guard
                    let baseDate = calendar.date(
                        from: DateComponents(year: 2023, month: 10, day: 1)
                    ),
                    let arrivalTime = calendar.date(
                        byAdding: .minute,
                        value: $0 + 3,
                        to: baseDate
                    )
                else {
                    return nil
                }

                let finishTime = arrivalTime.addingTimeInterval(Double.random(in: 30...300))

                return Agent(
                    id: String($0),
                    operation: $0 % 2 == 0 ? .write : .read,
                    arrivalTime: arrivalTime,
                    finishTime: finishTime
                )
            }
        )
    }
}
