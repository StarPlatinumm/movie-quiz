//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Артем Кривдин on 16.03.2024.
//

import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    func showAlert(alert: Alert) {
        let alertController = UIAlertController(
            title: alert.title,
            message: alert.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: alert.buttonText, style: .default) { _ in
            alert.completion()
        }
        
        alertController.addAction(action)
        delegate?.didReceiveAlert(alert: alertController)
    }
}
