//
//  TitleViewModifier.swift
//  CameraDemo
//
//  Created by Denis Silko on 16.04.2024.
//

import SwiftUI

struct TitleViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .bold()
            .multilineTextAlignment(.center)
    }
}

extension View {
    func titleStyle() -> some View {
        modifier(TitleViewModifier())
    }
}
