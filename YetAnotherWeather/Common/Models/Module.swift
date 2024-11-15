//
//  Module.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 26.09.2024.
//

import Foundation
import UIKit

final class Module<T> {
    
    let viewController: UIViewController
    let moduleInput: T
    
    init(viewController: UIViewController, moduleInput: T) {
        self.viewController = viewController
        self.moduleInput = moduleInput
    }
}
