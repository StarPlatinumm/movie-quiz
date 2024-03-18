//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Артем Кривдин on 16.03.2024.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func didReceiveAlert(alert: UIAlertController?)
}
