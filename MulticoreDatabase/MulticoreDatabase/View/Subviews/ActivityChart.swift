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
    var isWriting: Bool

    var body: some View {
        VStack {
            HStack {
                Text("Читателей: \(activeReaders)")
                    .foregroundColor(.green)
                Spacer()
                Text(isWriting && activeReaders == 0 ? "Запись активна" : "Нет записи")
                    .foregroundColor(isWriting ? .red : .gray)
            }
            .padding()

            Chart {
                BarMark(
                    x: .value("Активность", "Читатели"),
                    y: .value("Читатели", activeReaders)
                )
                .foregroundStyle(.green)

                BarMark(
                    x: .value("Активность", "Запись"),
                    y: .value("Запись", isWriting && activeReaders == 0 ? 1 : 0)
                )
                .foregroundStyle(.red)
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
    ActivityChart(activeReaders: 4, isWriting: true)
}

/*
 Модель конкурентного доступа к таблице базы данных под управлением PostgreSQL на многоядерном процессоре
*/
