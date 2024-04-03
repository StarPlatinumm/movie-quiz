//
//  String+Extensions.swift
//  MovieQuiz
//
//  Created by Артем Кривдин on 01.04.2024.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
