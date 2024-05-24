//
//  Screen.swift
//  CameraDemo
//
//  Created by Denis Silko on 09.04.2024.
//

import SwiftUI

enum Screen {
    case home
    case capture
}

extension Screen: NavigableScreen {
    @ViewBuilder
    var view: some View {
        switch self {
        case .home: viewFactory.makeHomeView()
        case .capture: viewFactory.makeCaptureView()
        }
    }
}
