import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol = StatisticServiceImplementation()
    private var moviesLoader: MoviesLoader = MoviesLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // показываем индикатор загрузки
        showLoadingIndicator(true)
        
        // подключаем QuestionFactory и загружаем данные
        questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
        questionFactory?.loadData()
        
        // подключаем AlertPresenter
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
        // настраиваем рамку картинки
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = UIColor.ypBlack.cgColor // делаем рамку черной (невидимой)
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
    }
    
    // нажатие кнопки "Да"
    @IBAction private func yesButtonClicked() {
        showAnswerResult(answer: true)
    }
    
    // нажатие кнопки "Нет"
    @IBAction private func noButtonClicked() {
        showAnswerResult(answer: false)
    }
    
    private func showAnswerResult(answer: Bool) {
        enableButtons(false) // блокируем кнопки на время
        let isCorrentAnswer = (answer == currentQuestion?.correctAnswer)
        imageView.layer.borderColor = isCorrentAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor // меняем цвет рамки
        if isCorrentAnswer { correctAnswers += 1 }
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // код, который мы хотим вызвать через 1 секунду
            guard let self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            // идём в состояние "Результат квиза"
            
            // сохраняем результат
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            // вызываем алерт
            let bestGame = statisticService.bestGame
            alertPresenter?.showAlert(alert: Alert(
                title: "Раунд окончен",
                message: """
                    Ваш результат: \(correctAnswers) из \(questionsAmount)
                    Количество сыгранных квизов: \(statisticService.gamesCount)
                    Рекорд: \(bestGame.correct) из \(bestGame.total) (\(bestGame.date))
                    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """,
                buttonText: "Сыграть ещё раз",
                alertId: "Game results",
                completion: { [weak self] in
                    guard let self else { return }
                    
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    
                    questionFactory?.requestNextQuestion()
                }))
        } else {
            currentQuestionIndex += 1
            // идём в состояние "Вопрос показан"
            questionFactory?.requestNextQuestion()
        }
        enableButtons(true) // разблокируем кнопки
    }
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func showQuestion(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // блокирует нажатие кнопок да/нет
    private func enableButtons(_ enabled: Bool) {
        yesButton.isEnabled = enabled
        noButton.isEnabled = enabled
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.showQuestion(quiz: viewModel)
        }
    }
    
    // MARK: - AlertPresenterDelegate
    
    func didReceiveAlert(alert: UIAlertController?) {
        guard let alert else { return }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Network
    
    private func showLoadingIndicator(_ value: Bool) {
        if value {
            activityIndicator.startAnimating()
            mainStackView.isHidden = true
        } else {
            activityIndicator.stopAnimating()
            mainStackView.isHidden = false
        }
        
    }
    
    private func showNetworkError(message: String) {
        let alert = Alert(title: "Ошибка",
                          message: message,
                          buttonText: "Попробовать еще раз",
                          alertId: nil) { [weak self] in
            guard let self = self else { return }
            
            // пробуем загрузить данные ещё раз
            showLoadingIndicator(true)
            questionFactory?.loadData()
        }
        
        alertPresenter?.showAlert(alert: alert)
    }
    
    func didLoadDataFromServer() {
        showLoadingIndicator(false) // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
}
