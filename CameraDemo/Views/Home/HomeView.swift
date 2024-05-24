//
//  HomeView.swift
//  CameraDemo
//
//  Created by Denis Silko on 16.05.2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @EnvironmentObject var coordinator: NavigationCoordinator<Screen>
    @State var showAlert = false
    
    var body: some View {
        content
            .onAppear { viewModel.send(event: .onAppear) }
            .onReceive(viewModel.$state, perform: navigating)
            .onReceive(viewModel.$state, perform: showingAlert)
            .alert(isPresented: $showAlert, content: goToSettingsAlert)
    }
    
    // MARK: - 
    
    func navigating(_ state: HomeViewModel.State) {
        if case .navigating(let transition) = state {
            switch transition {
            case .capture: coordinator.push(.capture)
            }
        }
    }
    
    func showingAlert(_ state: HomeViewModel.State) {
        if case .showingGoToSettingsAlert = state {
            showAlert = true
        } else {
            showAlert = false
        }
    }
    
    func goToSettingsAlert() -> Alert {
        Alert(
            title: Text("Camera Access Required"),
            message: Text("Please enable camera access in your device settings."),
            primaryButton: .default(Text("Go to Settings"), action: {
                viewModel.send(event: .onTap(.goToSettings))}),
            secondaryButton: .cancel(Text("Cancel"), action: {
                viewModel.send(event: .onTap(.cancel))})
        )
    }
    
    // MARK: -
    
    @ViewBuilder var content: some View {
        if case let .error(error) = viewModel.state {
            errorView(error)
        } else {
            main
        }
    }
    
    private var main: some View {
        ZStack {
            background
            
            VStack {
                top
                Spacer()
                buttons
            }
        }
    }
    
    // MARK: -
    
    private var background: some View {
        LinearGradient(gradient: Gradient(colors: [.blue, .white]),
                       startPoint: .top, endPoint: .bottom)
        .opacity(0.8)
        .ignoresSafeArea()
    }
    
    private var top: some View {
        VStack(spacing: 30) {
            Text("🤳🏽").font(.system(size: 140))
            Text("Combine Camera").titleStyle()
        }
        .padding(.top, 50)
    }
    
    private var buttons: some View {
        VStack {
            ButtonView("Front", color: .blue) {
                viewModel.send(event: .onTap(.capture(.front)))
            }
            
            ButtonView("Back", color: .blue) {
                viewModel.send(event: .onTap(.capture(.back)))
            }
        }
        .padding()
    }
    
    private func errorView(_ error: Error) -> some View {
        ErrorView(error) { viewModel.send(event: .onTap(.ok)) }
    }
}

#Preview {
    RootView(.home)
}
