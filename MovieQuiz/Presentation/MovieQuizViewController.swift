import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol = StatisticServiceImplementation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // подключаем QuestionFactory
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        // подключаем AlertPresenter
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter

        // настраиваем рамку картинки
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = UIColor.ypBlack.cgColor // делаем рамку черной (невидимой)
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки

        questionFactory.requestNextQuestion()
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
            let msgCurrentResult = "Ваш результат: \(correctAnswers) из \(questionsAmount)"
            let msgGamesPlayed = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let msgBestGame = "Рекорд: \(bestGame.correct) из \(bestGame.total) (\(bestGame.date))"
            let msgTotalAccuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            alertPresenter?.showAlert(alert: Alert(
                title: "Раунд окончен",
                message: "\(msgCurrentResult)\n\(msgGamesPlayed)\n\(msgBestGame)\n\(msgTotalAccuracy)",
                buttonText: "Сыграть ещё раз",
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
            image: UIImage(named: model.image) ?? UIImage(),
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
}
