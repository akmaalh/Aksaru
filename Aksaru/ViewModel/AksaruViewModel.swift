//
//  AksaruViewModel.swift
//  Aksaru
//
//  Created by Akmal Hakim on 20/05/24.
//

import Foundation
import SwiftData
import SwiftUI

class LetterListViewModel: ObservableObject {
    @Published var letters: [LetterModel] = []
    
    init() {
        loadLetters()
    }

    func loadLetters() {
        letters = [
            LetterModel(name: "a", isSwara: true),
            LetterModel(name: "ba"),
            LetterModel(name: "ca"),
            LetterModel(name: "da"),
            LetterModel(name: "e", isSwara: true),
            LetterModel(name: "ae", isSwara: true),
            LetterModel(name: "eu", isSwara: true),
            LetterModel(name: "ga"),
            LetterModel(name: "ha"),
            LetterModel(name: "i", isSwara: true),
            LetterModel(name: "ja"),
            LetterModel(name: "ka"),
            LetterModel(name: "la"),
            LetterModel(name: "ma"),
            LetterModel(name: "na"),
            LetterModel(name: "nga"),
            LetterModel(name: "nya"),
            LetterModel(name: "o", isSwara: true),
            LetterModel(name: "pa"),
            LetterModel(name: "ra"),
            LetterModel(name: "sa"),
            LetterModel(name: "ta"),
            LetterModel(name: "u", isSwara: true),
            LetterModel(name: "wa"),
            LetterModel(name: "ya")
        ]
    }
}

class PracticeViewModel: ObservableObject {
    @Published var letter: LetterModel
    @Published var predictionResult: String = ""
    @Published var showModal: Bool = false
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var isAnswerCorrect: Bool = false
    @Published var isSubmitPressed: Bool = false
    
    init(letter: LetterModel) {
        self.letter = letter
    }

    func submitAnswer(predictedLetter: String) {
        toastMessage = predictedLetter == letter.name ? "Correct!" : "Wrong!"
        showToast = true
        if predictedLetter != letter.name {
            showModal = true
            predictionResult = "Predicted: \(predictedLetter == "ae" ? "ae" : predictedLetter), but the correct answer is \(letter.name == "ae" ? "é": letter.name)."
        }
        isAnswerCorrect = predictedLetter == letter.name
        isSubmitPressed = true
    }

    func clearAnswer() {
        predictionResult = ""
        isAnswerCorrect = false
        isSubmitPressed = false
    }
}

class QuizManagerVM : ObservableObject {
    
    static let allLetters = [
        LetterModel(name: "a"),
        LetterModel(name: "ae"),
        LetterModel(name: "ba"),
        LetterModel(name: "ca"),
        LetterModel(name: "da"),
        LetterModel(name: "e"),
        LetterModel(name: "eu"),
        LetterModel(name: "ga"),
        LetterModel(name: "ha"),
        LetterModel(name: "i"),
        LetterModel(name: "ja"),
        LetterModel(name: "ka"),
        LetterModel(name: "la"),
        LetterModel(name: "ma"),
        LetterModel(name: "na"),
        LetterModel(name: "nga"),
        LetterModel(name: "nya"),
        LetterModel(name: "o"),
        LetterModel(name: "pa"),
        LetterModel(name: "ra"),
        LetterModel(name: "sa"),
        LetterModel(name: "ta"),
        LetterModel(name: "u"),
        LetterModel(name: "wa"),
        LetterModel(name: "ya")
    ]

    
    static var quizData: [QuizModel] {
        var quizData: [QuizModel] = []
        for _ in 0..<5 {
            let randomLetters = allLetters.shuffled().prefix(5)
            let questions = randomLetters.map {letter in
                QuestionModel(letterAsked: LetterModel(name: letter.name), points: 0)
            }
            quizData.append(QuizModel(timeTaken: 0, questions: questions))
        }
        return quizData
    }
    static var currentIndex = 0

    static func createGameModel(i:Int) -> Quiz {
        return Quiz(currentQuestionIndex: 0, quizModel: quizData[i])
    }

    @Published var model = QuizManagerVM.createGameModel(i: QuizManagerVM.currentIndex)

    var timer = Timer()
    var maxProgress = 5
    @Published var progress = 0

    init() {
        self.start()
    }

    func verifyAnswer(answer: String) {
        model.quizModel.questions[model.currentQuestionIndex].letterPredicted = answer
        model.quizModel.questions[model.currentQuestionIndex].points = model.quizModel.questions[model.currentQuestionIndex].isCorrect ? 1 : 0
        model.quizModel.questions[model.currentQuestionIndex].points = model.quizModel.questions[model.currentQuestionIndex].isCorrect ? 1 : 0
        model.currentQuestionIndex += 1
        progress += 1
        if model.currentQuestionIndex == model.quizModel.questions.count {
            timer.invalidate()
        }
    }

    func restartGame() {
        QuizManagerVM.currentIndex = 0
        model = QuizManagerVM.createGameModel(i: QuizManagerVM.currentIndex)
        progress = 0
        start()
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.progress += 1
            if self.progress == self.maxProgress {
                timer.invalidate()
            }
        }
    }

    func reset() {
        progress = 0
        timer.invalidate()
    }
}
