//
//  ActivityChart.swift
//  MulticoreDatabase
//
//  Created by Dmitriy Permyakov on 17.12.2024.
//

import SwiftUI
import Charts

struct ActivityChart: View {
    var activeReaders: Int

    var body: some View {
        VStack {
            Text("Читателей: \(activeReaders)")
                .foregroundColor(.green)
            .padding()

            Chart {
                BarMark(
                    x: .value("Активность", "Читатели"),
                    y: .value("Читатели", activeReaders)
                )
                .foregroundStyle(.green)
            }
            .frame(height: 200)
        }
        .padding()
        .background(.background, in: .rect(cornerRadius: 10))
        .overlay(
            Text("Активность читателей и записи")
                .font(.headline)
                .padding(),
            alignment: .topLeading
        )
    }
}

#Preview {
    ActivityChart(activeReaders: 4)
}
