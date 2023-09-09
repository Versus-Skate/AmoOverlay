//
//  CloseButton.swift
//  AmoOverlay
//
//  Created by Benoit Cotte on 09/09/2023.
//
import UIKit

class CloseButton: UIButton {
    weak var parentView: UIView? // Reference to the parent floating item
    weak var floatinItemView: FloatinItemView?
    var impactFeedbackLight: UIImpactFeedbackGenerator?
    var impactFeedbackHeavy: UIImpactFeedbackGenerator?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        setTitle("✕", for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .boldSystemFont(ofSize: 20)
        let _backgroundColor = UIColor(
            red: CGFloat(0) / 255.0,
            green: CGFloat(0) / 255.0,
            blue: CGFloat(0) / 255.0,
            alpha: 0.4
        )
        backgroundColor = _backgroundColor
        
        layer.cornerRadius = bounds.width / 2 // Make it a circle, adjust the radius as needed
        layer.opacity = 0
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0
        addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        impactFeedbackLight = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackHeavy = UIImpactFeedbackGenerator(style: .heavy)
        
        if gesture.state == .began {
            // Feedback when the user touches down
            impactFeedbackLight?.impactOccurred()
        } else if gesture.state == .ended {
            // Handle the long press ended event
            floatinItemView?.closeView()
            impactFeedbackHeavy?.impactOccurred()
            hide()
        }
        
        // Clean up the feedback generator
        impactFeedbackLight = nil
        impactFeedbackHeavy = nil
    }
    
    func show() {
        UIView.animate(withDuration: 0.2) {
            self.layer.opacity = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2) {
            self.layer.opacity = 0
        }
    }
    
    
}
