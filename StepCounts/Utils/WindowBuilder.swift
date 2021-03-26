//
//  WindowBuilder.swift
//  StepCounts
//
//  Created by Ashish Dwivedi on 26/03/21.
//

import UIKit

final class WindowBuilder {
    private(set) var window: UIWindow?
    
    
    // MARK: - Initialization
    
    init(_ scene: UIWindowScene) {
        self.window = UIWindow(windowScene: scene)
    }
    
    
    // MARK: - Public Methods
    
    func setRootViewController() {
        let homeViewModel = HomeViewModel()
        if let rootViewController = Routes.viewController(from: homeViewModel) {
            self.window?.rootViewController = rootViewController
        }
        
        self.window?.makeKeyAndVisible()
    }
}
