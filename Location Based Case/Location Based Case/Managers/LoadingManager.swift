//
//  LoadingManager.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 20.04.2025.
//

import UIKit

final class LoadingManager {
    private static var activityIndicator: UIActivityIndicatorView?
    private static var containerView: UIView?
    
    static func showLoading() {
        DispatchQueue.main.async {
            // Only show if not already showing
            guard containerView == nil else { return }
            
            // Get main window (iOS 15+ approach)
            let window: UIWindow?
            
            if #available(iOS 15.0, *) {
                // Modern approach for iOS 15+
                window = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first(where: { $0.activationState == .foregroundActive })?
                    .keyWindow
            } else {
                // Fallback for older iOS versions
                window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
            }
            
            guard let window = window else {
                print("LoadingManager: Could not find key window")
                return
            }
            
            // Create container view
            let container = UIView(frame: window.bounds)
            container.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            
            // Create loading effect with blur
            let blurEffect = UIBlurEffect(style: .systemMaterial)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            blurView.center = container.center
            blurView.clipsToBounds = true
            blurView.layer.cornerRadius = 10
            
            // Create activity indicator
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.center = CGPoint(x: blurView.bounds.width/2, y: blurView.bounds.height/2)
            indicator.color = .label
            indicator.startAnimating()
            
            // Add views
            blurView.contentView.addSubview(indicator)
            container.addSubview(blurView)
            window.addSubview(container)
            
            // Save references
            containerView = container
            activityIndicator = indicator
        }
    }
    
    static func hideLoading() {
        DispatchQueue.main.async {
            // Remove views if they exist
            activityIndicator?.stopAnimating()
            containerView?.removeFromSuperview()
            
            // Clear references
            activityIndicator = nil
            containerView = nil
        }
    }
}

// MARK: - UIViewController Extension
extension UIViewController {
    func showLoading() {
        LoadingManager.showLoading()
    }
    
    func hideLoading() {
        LoadingManager.hideLoading()
    }
} 
