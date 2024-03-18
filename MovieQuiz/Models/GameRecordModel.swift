//
//  GameRecordModel.swift
//  MovieQuiz
//
//  Created by Артем Кривдин on 17.03.2024.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: String

    func isBetterThan(_ another: GameRecord) -> Bool {
        correct > another.correct
    }
}
