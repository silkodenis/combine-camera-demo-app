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

struct RootView: View {
    @ObservedObject private var coordinator: NavigationCoordinator<Screen>
    private let root: Screen
    
    internal init(_ root: Screen, withParent coordinator: NavigationCoordinator<Screen>? = nil) {
        self.root = root
        self.coordinator = NavigationCoordinator<Screen>()
        self.coordinator.parent = coordinator
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            root.view
                .navigationDestination(for: Screen.self) { screen in
                    screen.view
                }
                .sheet(item: $coordinator.modal) { screen in
                    RootView(screen, withParent: coordinator)
                }
        }
        .environmentObject(coordinator)
    }
}
