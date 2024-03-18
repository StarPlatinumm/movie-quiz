//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Артем Кривдин on 16.03.2024.
//

import Foundation

struct Alert {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)
}
