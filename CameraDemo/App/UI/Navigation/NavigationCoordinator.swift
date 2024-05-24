/*
 * Copyright (c) [2024] [Denis Silko]
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *     https://github.com/silkodenis/swiftui-navigation-coordinator
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import SwiftUI

protocol NavigableScreen: Hashable, Identifiable {
    associatedtype ContentView: View
    @ViewBuilder var view: ContentView { get }
}

extension NavigableScreen {
    var id: UUID { UUID() }
}

final class NavigationCoordinator<V: NavigableScreen>: ObservableObject {
    @Published var path = NavigationPath()
    @Published var parent: NavigationCoordinator<V>?
    @Published var modal: V?
    var segues: [Identifier : Segue] = [:]
    
    // MARK: - Stack Navigation
    
    func push(_ value: V) {
        path.append(value)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
            removeInvalidSegues()
        }
    }

    func popToRoot() {
        if !path.isEmpty {
            path.removeLast(path.count)
            segues.removeAll()
        }
    }
    
    func unwind(to identifier: Identifier, with value: Any? = nil) {
        guard let segue = segues[identifier], path.count > segue.index, segue.type == .unwind else { return }
        
        path.removeLast(path.count - segue.index)
        segue.action?(value)
    }
    
    // MARK: - Modal Presentation
    
    func present(_ value: V) {
        modal = value
    }
    
    func dismiss(to identifier: Identifier? = nil, with value: Any? = nil) {
        guard let identifier = identifier, let segue = parent?.segues[identifier], 
                segue.type == .dismiss else {
            parent?.modal = nil
            return
        }
        
        parent?.modal = nil
        segue.action?(value)
    }
}

extension NavigationCoordinator {
    typealias Identifier = String
    
    struct Segue {
        let type: SegueType
        let index: Int
        let action: ((Any?) -> Void)?
        
        enum SegueType {
            case unwind
            case dismiss
        }
    }
    
    public func registerSegue(_ type: Segue.SegueType, with identifier: Identifier, action: ((Any?) -> Void)? = nil) {
        segues[identifier] = Segue(type: type, index: path.count, action: action)
    }
    
    private func removeInvalidSegues() {
        segues.keys.forEach { identifier in
            if let segueIndex = segues[identifier]?.index, segueIndex >= path.count {
                segues.removeValue(forKey: identifier)
            }
        }
    }
}
