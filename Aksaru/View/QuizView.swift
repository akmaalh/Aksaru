//
//  QuizView.swift
//  Aksaru
//
//  Created by Akmal Hakim on 20/05/24.
//

import SwiftUI
import PencilKit
import CoreML
import Vision

struct QuizView: View {
    @StateObject private var viewModel = QuizManagerVM()
    @State private var canvasView = PKCanvasView()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            if viewModel.model.currentQuestionIndex < viewModel.model.quizModel.questions.count {
                Text("Latihan Menulis")
                  .font(
                    Font.custom("Chubbo", size: 64)
                      .weight(.bold)
                  )
                  .multilineTextAlignment(.center)
                  .foregroundColor(.black)
                  .frame(maxWidth: .infinity, alignment: .top)

                VStack(alignment: .center, spacing: -81)  {
                    VStack {
                        HStack {
                            ForEach(viewModel.model.quizModel.questions.indices, id: \.self) { index in
                                if index < viewModel.model.currentQuestionIndex {
                                    Image(systemName: viewModel.model.quizModel.questions[index].isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(viewModel.model.quizModel.questions[index].isCorrect ? .green : .red)
                                } else if index == viewModel.model.currentQuestionIndex {
                                    Image(systemName: "questionmark.circle.fill")
                                        .foregroundColor(.blue)
                                } else {
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(.gray)
                                        .opacity(0.5)
                                }
                            }
                        }
                        Text(viewModel.model.quizModel.questions[viewModel.model.currentQuestionIndex].letterAsked.name == "ae" ? "é" : viewModel.model.quizModel.questions[viewModel.model.currentQuestionIndex].letterAsked.name)
                            .font(.system(size: 96, weight: .bold, design: .rounded))
                    }
                    .padding(.horizontal, 64)
                    .padding(.vertical, 24)
                    .background(Color(red: 0.93, green: 0.66, blue: 0.49))

                    .cornerRadius(24)
                    CanvasViewRepresentable(canvasView: $canvasView)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .border(Color(red: 0.93, green: 0.66, blue: 0.49), width: 4)
                    .zIndex(-1)
                }
                
                HStack {
                    Button(action: clearCanvas) {
                        Text("Clear")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    Button(action: {
                        let image = preprocessImage()
                        predictImage2(image: image)
                    }) {
                        Text("Submit")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            } else {
                Text("Latihan Selesai!")
                    .font(
                      Font.custom("Chubbo", size: 64)
                        .weight(.bold)
                    )
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .top)
                
                List(viewModel.model.quizModel.questions) { question in
                    HStack {
                        Text("Letter asked: \(question.letterAsked.name)")
                        if question.isCorrect {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.green)
                                .font(.system(size: 16))
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color.red)
                                .font(.system(size: 16))
                        }
                        Text("Letter predicted: \(question.letterPredicted ?? "N/A")")
                    }
                }
                
                Button("Restart") {
                    viewModel.restartGame()
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.reset()
        }
        .padding(24)
    }
    
    func preprocessImage() -> UIImage {
        let canvasBounds = canvasView.bounds
        let uiImage = canvasView.drawing.image(from: canvasBounds, scale: UIScreen.main.scale)
        let resizedImage = resizeImage(image: uiImage, targetSize: CGSize(width: 360, height: 360)) // Resize to 360x360

        let coloredImage = resizedImage.addBackgroundColor(color: colorScheme == .dark ? .black : .white)

        return coloredImage
    }

    func predictImage2(image: UIImage) {
        guard let pixelBuffer = image.toCVPixelBuffer() else {            return
        }

        guard let result = try? AksarunV2().prediction(image: pixelBuffer) else {
            return
        }
        
        
        viewModel.verifyAnswer(answer: result.target)
        clearCanvas()
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        let newSize = widthRatio > heightRatio ? CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? image
    }
    
    func clearCanvas() {
        canvasView.drawing = PKDrawing()
    }
}


#Preview {
    QuizView()
}
