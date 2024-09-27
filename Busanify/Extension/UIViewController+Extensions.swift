//
//  UIViewController+Extensions.swift
//  Busanify
//
//  Created by 이인호 on 9/27/24.
//

import UIKit

extension UIViewController: UIGestureRecognizerDelegate {
    
    func enableInteractivePopGesture() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func disableInteractivePopGesture() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
