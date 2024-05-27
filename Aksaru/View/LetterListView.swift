//
//  LetterListView.swift
//  Aksaru
//
//  Created by Akmal Hakim on 20/05/24.
//

import SwiftUI
import PencilKit

struct LetterListView: View {
    @StateObject private var viewModel = LetterListViewModel()
    @ViewBuilder
    private func letterRow(letter: LetterModel) -> some View {
        ZStack(alignment: .leading) {
            NavigationLink(destination: PracticeView(letter: letter)) {
                EmptyView()
            }
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .center, spacing: 10) {
                    Image(letter.name + "_indigo")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                .padding(8)
                .background(Color(red: 0.75, green: 0.7, blue: 0.89))
                .cornerRadius(16)
                Text(letter.name == "ae" ? "é" : letter.name)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 0.35, green: 0.34, blue: 0.84))
            .cornerRadius(24)
        }
        .listRowSeparator(.hidden)
    }
    
    var body: some View {
        NavigationView {
            HStack {
                List {
                    Section(header: Text("Swara").font(.system(size: 24))) {
                        ForEach(viewModel.letters.filter { $0.isSwara }) { letter in
                            letterRow(letter: letter)
                        }
                    }

                    Section(header: Text("Ngalagena").font(.system(size: 24))) {
                        ForEach(viewModel.letters.filter { !$0.isSwara }) { letter in
                            letterRow(letter: letter)
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationTitle("Aksara List")
            }
        }
    }
}

struct PracticeView: View {
    @StateObject private var viewModel: PracticeViewModel
    @State private var canvasView = PKCanvasView()
    @Environment(\.colorScheme) var colorScheme

    init(letter: LetterModel) {
        _viewModel = StateObject(wrappedValue: PracticeViewModel(letter: letter))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .center, spacing: 0) {
                    Image(viewModel.letter.name + "_indigo")
                        .resizable()
                        .frame(width: 100, height: 100)
                    Text(viewModel.letter.name == "ae" ? "é" : viewModel.letter.name)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.35, green: 0.34, blue: 0.84))
                }
                .padding(.horizontal, 36)
                .padding(.vertical, 24)
                .background(Color(red: 0.75, green: 0.7, blue: 0.89))
                .cornerRadius(24)
                VStack(alignment: .trailing) {
                    resultView(isCorrect: viewModel.isAnswerCorrect, isSubmitPressed: viewModel.isSubmitPressed, letterName: viewModel.letter.name == "ae" ? "é" : viewModel.letter.name, predictedLetter: viewModel.predictionResult)
                    HStack(alignment: .center, spacing: 15) {
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
                }
            }
            HStack(alignment: .top, spacing: 12) {
                CanvasViewRepresentable(canvasView: $canvasView)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .border(Color(red: 0.75, green: 0.7, blue: 0.89), width: 2)
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .topLeading)
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
        guard let pixelBuffer = image.toCVPixelBuffer() else {
            viewModel.predictionResult = "Failed to convert image to pixel buffer"
            viewModel.showModal = true
            return
        }

        guard let result = try? AksarunV2().prediction(image: pixelBuffer) else {
            viewModel.predictionResult = "Failed to perform prediction"
            viewModel.showModal = true
            return
        }

        viewModel.predictionResult = result.target
        viewModel.showModal = true
        
        viewModel.submitAnswer(predictedLetter: result.target)
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
    LetterListView()
}

struct resultView: View {
    let isCorrect: Bool
    let isSubmitPressed: Bool
    let letterName: String
    let predictedLetter: String

    var body: some View {
        if isSubmitPressed {
            VStack(alignment: .leading) {
                HStack(alignment: .top, spacing: 11) {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isCorrect ? Color(red: 0.2, green: 0.78, blue: 0.35) : .red)
                        .font(.system(size: 36))
                    Text(isCorrect ? "Benar!" : "Salah!")
                        .font(Font.custom("Chubbo", size:36).weight(.bold))
                        .foregroundColor(isCorrect ? Color(red: 0.2, green: 0.78, blue: 0.35) : .red)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                Text(isCorrect ? letterName : "\(predictedLetter)")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .opacity(0.3)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, minHeight: 115, alignment: .center)
            .background(isCorrect ? Color(red: 0.86, green: 0.99, blue: 0.91) : Color(red: 0.99, green: 0.86, blue: 0.86))
            .cornerRadius(24)
        } else {
            Rectangle()
                .fill(Color(red: 0.75, green: 0.7, blue: 0.89))
                .frame(maxWidth: .infinity, maxHeight: 115)
                .cornerRadius(24)
                .opacity(0.4)
        }
    }
}
