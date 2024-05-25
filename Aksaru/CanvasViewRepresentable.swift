//
//  CanvasViewRepresentable.swift
//  Aksaru
//
//  Created by Akmal Hakim on 17/05/24.
//

import SwiftUI
import PencilKit

struct CanvasViewRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .pencilOnly
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
