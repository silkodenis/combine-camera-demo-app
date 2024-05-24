//
//  CaptureView.swift
//  CameraDemo
//
//  Created by Denis Silko on 09.05.2024.
//

import SwiftUI

struct CaptureView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator<Screen>
    @StateObject var viewModel: CaptureViewModel
    
    var body: some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: barBackButton)
            .onAppear { viewModel.send(event: .onAppear) }
            .onReceive(viewModel.$state, perform: navigating)
    }
    
    // MARK: -
    
    func navigating(_ state: CaptureViewModel.State) {
        if case .navigating(let transition) = state {
            switch transition {
            case .back: coordinator.pop()
            }
        }
    }
    
    // MARK: -
    
    var content: some View {
        ZStack {
            videoPreviewLayer
            buttons
        }
    }
    
    var videoPreviewLayer: some View {
        CameraVideoPreviewLayer(session: viewModel.session)
    }
    
    var buttons: some View {
        VStack {
            Spacer()
            
            HStack {
                Button(action: {viewModel.send(event: .onTap(.stopCaptureSession))}) {
                    Image(systemName: "stop.circle")
                }
                Spacer()
                Button(action: {viewModel.send(event: .onTap(.switchCamera))}) {
                    Image(systemName: "camera.rotate")
                }
                Spacer()
                Button(action: {viewModel.send(event: .onTap(.startCaptureSession))}) {
                    Image(systemName: "play.circle")
                }
            }
            .foregroundColor(.blue)
            .font(.largeTitle)
        }
        .padding()
    }
    
    var barBackButton: some View {
        Button(action: {viewModel.send(event: .onTap(.back))}) {
            Image(systemName: "chevron.left")
                .foregroundColor(.blue)
                .bold()
        }
    }
}

#Preview {
    RootView(.capture)
}
