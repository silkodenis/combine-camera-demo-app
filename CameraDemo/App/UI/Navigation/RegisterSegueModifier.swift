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

struct RegisterSegueModifier: ViewModifier {
    @EnvironmentObject var coordinator: NavigationCoordinator<Screen>
    
    let type: NavigationCoordinator<Screen>.Segue.SegueType
    let identifier: String
    let action: ((Any?) -> Void)?
    
    func body(content: Content) -> some View {
        content.onAppear {
            coordinator.registerSegue(type, with: identifier, action: action)
        }
    }
}

extension View {
    func onUnwind(segue identifier: String, perform action: ((Any?) -> Void)? = nil) -> some View {
        modifier(RegisterSegueModifier(type: .unwind, identifier: identifier, action: action))
    }
    
    func onDismiss(segue identifier: String, perform action: ((Any?) -> Void)? = nil) -> some View {
        modifier(RegisterSegueModifier(type: .dismiss, identifier: identifier, action: action))
    }
}
