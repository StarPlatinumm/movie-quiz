//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Артем Кривдин on 16.03.2024.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    
    func loadData()
}
