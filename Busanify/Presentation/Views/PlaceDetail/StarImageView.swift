//
//  StarImageView.swift
//  Busanify
//
//  Created by 이인호 on 7/23/24.
//

import UIKit

class StarImageView: UIImageView {

    var fillPercentage: CGFloat = 0 {
        didSet {
            applyMask()
        }
    }
    
    private func applyMask() {
        let maskLayer = CALayer()
        maskLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * fillPercentage, height: bounds.height)
        maskLayer.backgroundColor = UIColor.black.cgColor
        
        let maskView = UIView(frame: bounds)
        maskView.layer.addSublayer(maskLayer)
        
        self.mask = maskView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyMask()
    }
}
