//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Артем Кривдин on 20.04.2024.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func switchLoadingIndicator(isShown: Bool)
    
    func showNetworkError(message: String)
}
