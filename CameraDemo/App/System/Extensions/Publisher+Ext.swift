//
//  Publisher+Ext.swift
//  CameraDemo
//
//  Created by Denis Silko on 18.04.2024.
//

import Combine

extension Publisher where Failure == Never {
    func weakAssign<T: AnyObject>(to keyPath: ReferenceWritableKeyPath<T, Output>,
                                  on object: T) -> AnyCancellable 
    {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}
