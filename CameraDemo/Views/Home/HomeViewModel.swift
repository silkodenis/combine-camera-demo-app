//
//  MenuViewModel.swift
//  CameraDemo
//
//  Created by Denis Silko on 16.05.2024.
//

import Foundation
import CombineCamera
import Combine
import UIKit

class HomeViewModel: ObservableObject {
    @Published private(set) var state = State.idle
    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event, Never>()
    
    internal init(camera: Camera) {
        Publishers.system(
            initial: state,
            reduce: Self.reduce,
            scheduler: RunLoop.main,
            feedbacks: [
                Self.whenGoingToSettings(),
                Self.whenStartingCaptureSession(camera: camera),
                Self.userInput(input: input.eraseToAnyPublisher())
            ]
        )
        .weakAssign(to: \.state, on: self)
        .store(in: &bag)
    }
    
    func send(event: Event) {
        input.send(event)
    }
}

// MARK: - Inner Types

extension HomeViewModel {
    enum State {
        case idle
        case showingGoToSettingsAlert
        case goingToSettings
        case startingCaptureSession(CameraPosition)
        case navigating(Transition)
        case error(Error)
    }
    
    enum Event {
        case onAppear
        case onTap(Button)
        case onCameraAccessDenied
        case onCameraAccessDetermined
        case onCaptureSessionStarted
        case onSettingsOpened
        case onFailedToStartCaptureSession(Error)
    }
}

extension HomeViewModel {
    enum Transition {
        case capture
    }
    
    enum CameraPosition {
        case front
        case back
    }
    
    enum Button {
        case goToSettings
        case cancel
        case ok
        case capture(CameraPosition)
    }
}

// MARK: - State Machine

extension HomeViewModel {
    static func reduce(_ state: State, _ event: Event) -> State {
        print("🏠", event)
        
        switch state {
        case .idle:
            switch event {
            case .onTap(.capture(let position)):
                return .startingCaptureSession(position)
            default:
                return state
            }
            
        case .startingCaptureSession:
            switch event {
            case .onFailedToStartCaptureSession(let error):
                return .error(error)
            case .onCameraAccessDenied:
                return .idle
            case .onCameraAccessDetermined:
                return .showingGoToSettingsAlert
            case .onCaptureSessionStarted:
                return .navigating(.capture)
            default:
                return state
            }
            
        case .navigating:
            switch event {
            case .onAppear:
                return .idle
            default:
                return state
            }
            
        case .showingGoToSettingsAlert:
            switch event {
            case .onTap(.goToSettings):
                return .goingToSettings
            case .onTap(.cancel):
                return .idle
            default:
                return state
            }
            
        case .error:
            switch event {
            case .onTap(.ok):
                return .idle
            default:
                return state
            }
            
        case .goingToSettings:
            switch event {
            case .onSettingsOpened:
                return .idle
            default:
                return state
            }
        }
    }
    
    static func whenStartingCaptureSession(camera: Camera) -> Feedback<State, Event> {
        Feedback {(state: State) -> AnyPublisher<Event, Never> in
            guard case .startingCaptureSession(let position) = state else { return Empty().eraseToAnyPublisher() }

            return camera.startCapture(at: (position == .back) ? .back : .front)
                .map { Event.onCaptureSessionStarted }
                .catch { error in
                    switch error {
                    case .denied: 
                        return Just(Event.onCameraAccessDenied)
                    case .determined: 
                        return Just(Event.onCameraAccessDetermined)
                    default: 
                        return Just(Event.onFailedToStartCaptureSession(error))
                    }
                }
                .eraseToAnyPublisher()
        }
    }
    
    static func whenGoingToSettings() -> Feedback<State, Event> {
        Feedback {(state: State) -> AnyPublisher<Event, Never> in
            guard case .goingToSettings = state else { return Empty().eraseToAnyPublisher() }
            
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                    UIApplication.shared.canOpenURL(settingsUrl) else {
                return Empty().eraseToAnyPublisher()
            }
            
            UIApplication.shared.open(settingsUrl)
            
            return Just(Event.onSettingsOpened).eraseToAnyPublisher()
        }
    }
    
    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { _ in input}
    }
}
