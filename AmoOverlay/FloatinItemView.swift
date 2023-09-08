//
//  FloatinItemView.swift
//  AmoOverlay
//
//  Created by Benoit Cotte on 08/09/2023.
//

import UIKit

class FloatinItemView: UIView {
    private var isOpen = false // Maintain the open/closed state
    private var originalFrame: CGRect?
    
    private let paddingX: CGFloat = 20 // Adjust the X-axis padding as needed
    private let paddingY: CGFloat = 20 // Adjust the Y-axis padding as needed
    private let _cornerRadius: CGFloat = 40
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        // Customize the appearance of your view here
        backgroundColor = UIColor.blue
        layer.cornerRadius = _cornerRadius
        
        // Add a pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        
        // Add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        if isOpen {
            return
        }
        let translation = gesture.translation(in: self.superview)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        gesture.setTranslation(.zero, in: self.superview)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        // Toggle the open/closed state
        isOpen = !isOpen
        
        if isOpen {
            openView()
        } else {
            closeView()
        }
    }
    
    private func openView() {
        originalFrame = frame
        
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height
        let innerBounds = UIScreen.main.bounds.inset(by: UIEdgeInsets(top: statusBarHeight!, left: 0, bottom: 0, right: 0))

        let newFrame = CGRect(
            x: paddingX,
            y: paddingY + statusBarHeight!, // Add statusBarHeight to the Y coordinate
            width: innerBounds.width - (2 * paddingX),
            height: innerBounds.height - (2 * paddingY)
        )
        UIView.animate(withDuration: 0.3) {
            self.frame = newFrame
        }
    }
    
    private func closeView() {
        // If closed, animate the view back to the original size
        if let originalFrame = originalFrame {
            UIView.animate(withDuration: 0.3) {
                self.frame = originalFrame
            }
        }
    }
}
