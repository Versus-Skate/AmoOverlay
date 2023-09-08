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
            // If open, expand the view to take the full available width
            originalFrame = frame
            let newFrame = CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height
            )
            UIView.animate(withDuration: 0.3) {
                self.frame = newFrame
            }
        } else {
            // If closed, animate the view back to the original size
            if let originalFrame = originalFrame {
                UIView.animate(withDuration: 0.3) {
                    self.frame = originalFrame
                }
            }
        }
    }
}
