//
//  OptimizedDelegatesList.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 23.01.2025.
//

import Foundation

public func weakify<T: AnyObject>(_ object: T) -> (() -> T?) {
    { [weak object] in object }
}

/// Оптимизированный вариант `DelegatesList`
///
/// Создаётся следующим образом:
///
///     let delegatesList = OptimizedDelegatesList<IAppBadgesDelegate>()
///
/// Добавить делегат:
///
///     delegatesList.addDelegate(weakify(delegate))
///
/// Удалить делегат:
///
///     delegatesList.removeDelegate(delegate)
final public class OptimizedDelegatesList<T>: Sequence {

    // Private
    private var delegates = [() -> T?]([])

    // MARK: - Public

    public init() { }

    /// Добавляет элемент в список.
    ///
    /// - Parameter delegate: Элемент, который будет добавлен.
    public func addDelegate(_ delegate: @escaping () -> T?) {
        delegates.append(delegate)
    }

    /// Удаляет элемент из списка.
    ///
    /// - Parameter delegate: Элемент, который будет удален.
    public func removeDelegate(_ delegate: T) {
        let delegate = delegate as AnyObject
        delegates.removeAll(where: { $0() as AnyObject === delegate })
    }

    /// Количество элементов в списке.
    public var count: Int {
        delegates.count
    }

    /// Является ли коллекция пустой.
    public var isEmpty: Bool {
        return count == 0
    }

    // MARK: - Sequence

    /// Возвращает итератор для перебора элементов коллекции.
    public func makeIterator() -> Array<T>.Iterator {
        delegates.compactMap { $0() }.makeIterator()
    }
}
