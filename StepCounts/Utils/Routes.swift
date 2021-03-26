//
//  Routes.swift
//  StepCounts
//
//  Created by Ashish Dwivedi on 26/03/21.
//

import UIKit

final class Routes {
    static func viewController(from viewModel: ViewModel) -> UIViewController? {
        switch viewModel {
            case let homeViewModel as HomeViewModel:
                return HomeViewController(with: homeViewModel)
            default: break
        }
        
        return nil
    }
}
