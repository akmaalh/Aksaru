//
//  ContentView.swift
//  Aksaru
//
//  Created by Akmal Hakim on 15/05/24.
//

import SwiftUI
import PencilKit
import CoreML
import Vision


struct PredictView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var canvasView = PKCanvasView()
    @State private var image: Image? = nil
    @State private var predictionResult: String = ""
    @State private var showModal: Bool = false
    
    var body: some View {
        VStack {
            CanvasViewRepresentable(canvasView: $canvasView)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .border(Color.gray, width: 1)
            
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .border(Color.black, width: 1)
            }
            
            HStack {
                Button(action: saveDrawingAsImage) {
                    Text("Save Drawing as Image")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .font(.custom("Chubbo-Medium", size: 24))
                }
                
                Button(action: detectImage) {
                    Text("Predict Image")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .font(.custom("Chubbo-Medium", size: 24))
                }

                Button(action: clearCanvas) {
                    Text("Clear Canvas")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .font(.custom("Chubbo-Medium", size: 24))
                }
            }
            .padding()
        }
        .sheet(isPresented: $showModal) {
            VStack {
                Text("Prediction Result")
                    .font(.title)
                    .padding()
                
                Text(predictionResult)
                    .font(.body)
                    .padding()
                
                Button("Dismiss") {
                    showModal = false
                }
                .padding()
            }
        }
    }
    
    func saveDrawingAsImage() {
        let drawing = canvasView.drawing
        let bounds = drawing.bounds.insetBy(dx: -72, dy: -72) // Add 72px margin
        let image = drawing.image(from: bounds, scale: UIScreen.main.scale)
        self.image = Image(uiImage: image)
    }

    func clearCanvas() {
        canvasView.drawing = PKDrawing()
        image = nil
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
            predictionResult = "Failed to convert image to pixel buffer"
            showModal = true
            return
        }

        guard let result = try? AksarunV2().prediction(image: pixelBuffer) else {
            predictionResult = "Failed to perform prediction"
            showModal = true
            return
        }

        predictionResult = result.target
        showModal = true

        print(result.target)
    }

    func detectImage() {
        let resizedImage = preprocessImage()
        UIImageWriteToSavedPhotosAlbum(resizedImage, nil, nil, nil)
        predictImage2(image: resizedImage)
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
    
    func predictImage() {
        let canvasBounds = canvasView.bounds
        let uiImage = canvasView.drawing.image(from: canvasBounds, scale: UIScreen.main.scale)
        let resizedImage = resizeImage(image: uiImage, targetSize: CGSize(width: 360, height: 360)) // Resize to 360x360

        UIImageWriteToSavedPhotosAlbum(resizedImage, nil, nil, nil)

        guard let pixelBuffer = resizedImage.toCVPixelBuffer() else {
            predictionResult = "Failed to convert image to pixel buffer"
            showModal = true
            return
        }

        guard let result = try? AksarunV2().prediction(image: pixelBuffer) else {
            predictionResult = "Failed to perform prediction"
            showModal = true
            return
        }        
        // show prediction result on modal
        showModal = true
        
        guard let model = try? VNCoreMLModel(for: AksarunV2().model) else {
            predictionResult = "Failed to load model"
            showModal = true
            return
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            if let results = request.results as? [VNClassificationObservation] {
                if let firstResult = results.first {
                    print(firstResult.identifier, firstResult.confidence)
                    self.predictionResult = "\(firstResult.identifier) with probability \(firstResult.confidence)"
                } else {
                    self.predictionResult = "No prediction results found"
                }
            } else if let error = error {
                self.predictionResult = "Error: \(error.localizedDescription)"
            }
            showModal = true
        }
        
        guard let pixelBuffer = resizedImage.toCVPixelBuffer() else {
            predictionResult = "Failed to convert image to pixel buffer"
            showModal = true
            return
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)

        do {
            try handler.perform([request])
        } catch {
            predictionResult = "Failed to perform prediction"
            showModal = true
        }
    }

    func CGImageSaveToPhotosAlbum(_ cgImage: CGImage) {
        let uiImage = UIImage(cgImage: cgImage)
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
    }
}

extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }

        if let pixelBuffer = pixelBuffer {
            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)

            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

            context?.translateBy(x: 0, y: self.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)

            UIGraphicsPushContext(context!)
            self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
            UIGraphicsPopContext()
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

            return pixelBuffer
        }

        return nil
    }

    func addBackgroundColor(color: UIColor) -> UIImage {
        let rect = CGRect(origin: .zero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()
        UIRectFill(rect)
        self.draw(in: rect, blendMode: .normal, alpha: 1.0)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}

#Preview {
    PredictView()
}
