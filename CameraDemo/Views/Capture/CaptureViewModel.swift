//
//  CaptureViewModel.swift
//  CameraDemo
//
//  Created by Denis Silko on 10.05.2024.
//

import Foundation
import AVFoundation
import CombineCamera
import Combine

class CaptureViewModel: ObservableObject {
    @Published private(set) var state = State.idle
    public let session: AVCaptureSession
    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event, Never>()
    
    internal init(camera: Camera) {
        session = camera.captureSession

        Publishers.system(
            initial: state,
            reduce: Self.reduce,
            scheduler: RunLoop.main,
            feedbacks: [
                Self.whenStartingCaptureSession(camera: camera),
                Self.whenStoppingCaptureSession(camera: camera),
                Self.whenSwitchingCamera(camera: camera),
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

extension CaptureViewModel {
    enum State {
        case idle
        case switchingCamera
        case stoppingCaptureSession(cause: Event)
        case startingCaptureSession
        case navigating(Transition)
        case error(Error)
    }
    
    enum Event {
        case onAppear
        case onTap(Button)
        case onCameraSwitched
        case onCaptureSessionStarted
        case onCaptureSessionStopped
        case onFailedToStartCaptureSession(Error)
        case onFailedToSwitchCamera(Error)
    }
}

extension CaptureViewModel {
    enum Transition {
        case back
    }
    
    enum Button {
        case back
        case startCaptureSession
        case stopCaptureSession
        case switchCamera
    }
}

// MARK: - State Machine

extension CaptureViewModel {
    static func reduce(_ state: State, _ event: Event) -> State {
        print("🎥", event)
        
        switch state {
        case .idle:
            switch event {
            case .onAppear:
                return .startingCaptureSession

            case .onTap(let button):
                switch button {
                case .back:
                    return .stoppingCaptureSession(cause: event)
                case .startCaptureSession:
                    return .startingCaptureSession
                case .stopCaptureSession:
                    return .stoppingCaptureSession(cause: event)
                case .switchCamera:
                    return .switchingCamera
                }
            default:
                return state
            }
            
        case .stoppingCaptureSession(let cause):
            switch cause {
            case .onTap(.back): 
                return .navigating(.back)
            default:
                return .idle
            }
            
        case .startingCaptureSession, .switchingCamera:
            return .idle
            
        default: 
            return state
        }
    }
    
    static func whenStartingCaptureSession(camera: Camera) -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .startingCaptureSession = state else { return Empty().eraseToAnyPublisher() }
            
            return camera.startCapture()
                .map { Event.onCaptureSessionStarted }
                .catch { Just(Event.onFailedToStartCaptureSession($0)) }
                .eraseToAnyPublisher()
        }
    }
    
    static func whenStoppingCaptureSession(camera: Camera) -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .stoppingCaptureSession = state else { return Empty().eraseToAnyPublisher() }
            
            return camera.stopCapture()
                .map { Event.onCaptureSessionStopped }
                .eraseToAnyPublisher()
        }
    }
    
    static func whenSwitchingCamera(camera: Camera) -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .switchingCamera = state else { return Empty().eraseToAnyPublisher() }
            
            return camera.switchCamera()
                .map { Event.onCameraSwitched }
                .catch { Just(Event.onFailedToSwitchCamera($0)) }
                .eraseToAnyPublisher()
        }
    }
    
    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { _ in input }
    }
}
