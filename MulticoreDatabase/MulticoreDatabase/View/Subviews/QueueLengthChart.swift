//
//  QueueLengthChart.swift
//  MulticoreDatabase
//
//  Created by Dmitriy Permyakov on 17.12.2024.
//

import SwiftUI
import Charts

struct QueueLengthChart: View {
    var queueLengths: [(date: Date, Int)]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Длина очереди")
                .font(.headline)
                .padding()
            ScrollView(.horizontal) {
                HStack {
                    Chart {
                        ForEach(queueLengths, id: \.date) { point in
                            LineMark(
                                x: .value("Время", point.date),
                                y: .value("Длина очереди", point.1)
                            )
                            .foregroundStyle(.blue)
                        }
                    }
                    .frame(width: CGFloat(queueLengths.count) * 40)
                    .padding()
                }
            }
        }
        .frame(minHeight: 250)
        .background(.background, in: .rect(cornerRadius: 10))
    }
}

#Preview {
    QueueLengthChart(
        queueLengths: (1...100).map {
            (Date(), $0)
        }
    )
}
