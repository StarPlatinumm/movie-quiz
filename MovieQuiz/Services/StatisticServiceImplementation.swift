//
//  StaticServiceImplementation.swift
//  MovieQuiz
//
//  Created by Артем Кривдин on 17.03.2024.
//

import Foundation

class StatisticServiceImplementation: StatisticServiceProtocol {
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correctCount, questionsCount, totalAccuracy, bestGame, gamesCount
    }
    
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var correctCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.correctCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correctCount.rawValue)
        }
    }
    
    var questionsCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.questionsCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.questionsCount.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            return userDefaults.double(forKey: Keys.totalAccuracy.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        correctCount += count
        questionsCount += amount
        totalAccuracy = Double(correctCount) / Double(questionsCount) * 100
        
        let game = GameRecord(correct: count, total: amount, date: Date())
        if game.isBetterThan(bestGame) {
            bestGame = game
        }
    }
}
