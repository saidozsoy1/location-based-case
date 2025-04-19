//
//  SplashViewController.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 19.04.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    var onFinish: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("didload splash")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            print("Splash timer completed")
            self?.onFinish?()
        }
    }
}
