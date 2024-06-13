//
//  ICoordinator.swift
//  YetAnotherWeather
//
//  Created by Иван Гребенюк on 19.05.2024.
//

import UIKit
import Foundation

protocol ICoordinator: AnyObject {
    /// Содержит массив  координаторов дочерних экранов
    var childrenCoordinators: [ICoordinator] {get set}
    
    /// Вызывается при создании координатора
    func start()
    
    /// Удаляет из childrenCoordinators координатор экрана с которого мы ушли
    func finish(coordinator: ICoordinator)
}

extension ICoordinator {
    func finish(coordinator: ICoordinator) {
        childrenCoordinators = childrenCoordinators.filter { $0 !== coordinator }
    }
}
