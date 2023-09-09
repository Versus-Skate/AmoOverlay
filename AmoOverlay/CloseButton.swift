//
//  CloseButton.swift
//  AmoOverlay
//
//  Created by Benoit Cotte on 09/09/2023.
//
import UIKit

class CloseButton: UIButton {
    weak var parentFloatingItemView: FloatinItemView? // Reference to the parent floating item
    var impactFeedback: UIImpactFeedbackGenerator?
    
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
        backgroundColor = .red // Customize the background color as needed
        layer.cornerRadius = bounds.width / 2 // Make it a circle, adjust the radius as needed
        layer.opacity = 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        parentFloatingItemView?.closeView()
        
        // Create and prepare the feedback generator
        impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback?.prepare()

        // Trigger the impact feedback
        impactFeedback?.impactOccurred()

        // Clean up the feedback generator
        impactFeedback = nil
    }
    
    func show(fullScreenBounds: CGRect) {
        
        print("Should show")
        UIView.animate(withDuration: 0.1) {
            self.layer.opacity = 1
        }
    }
    
    func hide(fullScreenBounds: CGRect) {
        print("Should hide")
        UIView.animate(withDuration: 0.1) {
            self.layer.opacity = 0
        }
    }
    
    
}
