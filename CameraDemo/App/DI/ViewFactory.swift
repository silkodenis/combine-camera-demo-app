//
//  ViewFactory.swift
//  CameraDemo
//
//  Created by Denis Silko on 09.04.2024.
//

import SwiftUI
import CombineCamera

fileprivate final class AppFactory {
    fileprivate let camera: Camera

    fileprivate init() {
        self.camera = Camera(preset: .high, position: .back, orientation: .portrait)
    }
    
    fileprivate func makeCaptureViewModel() -> CaptureViewModel {
        CaptureViewModel(camera: camera)
    }
    
    fileprivate func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(camera: camera)
    }
}

internal let viewFactory = ViewFactory()

final internal class ViewFactory {
    fileprivate let appFactory = AppFactory()
    fileprivate init() {}
    
    func makeHomeView() -> some View {
        HomeView(viewModel: self.appFactory.makeHomeViewModel())
    }
    
    func makeCaptureView() -> some View {
        CaptureView(viewModel: self.appFactory.makeCaptureViewModel())
    }
}
