//
//  AksaraModel.swift
//  Aksaru
//
//  Created by Akmal Hakim on 20/05/24.
//

import Foundation
import SwiftData

struct LetterModel: Identifiable, Codable {
    var id = UUID()
    var name: String
    var isSwara: Bool = false
}

struct Quiz {
    var currentQuestionIndex: Int
    var quizModel: QuizModel
    var quizCompleted: Bool = false
    var quizResult: Double = 0
    var quizTimeTaken: TimeInterval = 0
}

struct QuizModel: Identifiable, Codable {
    var id = UUID()
    var timeTaken: TimeInterval
    var questions: [QuestionModel]
}

struct QuestionModel: Identifiable, Codable {
    var id = UUID()
    var letterAsked: LetterModel
    var letterPredicted: String?
    var points: Double

    var isCorrect: Bool {
        return letterPredicted == letterAsked.name
    }

    enum CodingKeys: String, CodingKey {
        case id, letterAsked, letterPredicted, points
    }
}
