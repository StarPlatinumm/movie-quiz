//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Артем Кривдин on 16.03.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didRecieveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
