//
//  ErrorView.swift
//  CameraDemo
//
//  Created by Denis Silko on 20.04.2024.
//

import SwiftUI

struct ErrorView: View {
    let error: Error
    let ok: () -> Void
    
    internal init(_ error: any Error, okAction: @escaping () -> Void) {
        self.error = error
        self.ok = okAction
    }
    
    var body: some View {
        VStack(spacing: 15) {
            title
            text
            button
        }
        .onAppear {
            UIImpactFeedbackGenerator(style: .medium)
                .impactOccurred()
        }
    }

    private var title: some View {
        Text("🤷‍♂️").font(.system(size: 100))
    }
    
    private var text: some View {
        Text(error.localizedDescription)
    }
    
    private var button: some View {
        Button("Ok", action: ok).bold()
    }
}

#Preview {
    ErrorView(URLError(.badURL)) {}
}
