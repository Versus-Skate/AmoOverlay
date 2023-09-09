//
//  FloatinItemView.swift
//  AmoOverlay
//
//  Created by Benoit Cotte on 08/09/2023.
//

import UIKit

class GestureDelegate: NSObject, UIGestureRecognizerDelegate {
    var isOpen: Bool = false // Shared open/closed state
    var isExpanded: Bool = false // Shared open/closed state

    // Specify that when the view is open, only allow swipe gestures.
    // When the view is closed, allow both pan and tap gestures.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if isExpanded {
            return gestureRecognizer is UISwipeGestureRecognizer
        }
        if isOpen {
            // Only allow swipe gestures when the view is open.
            return gestureRecognizer is UISwipeGestureRecognizer
        } else {
            // Allow both pan and tap gestures when the view is closed.
            return true
        }
    }
}

class FloatinItemView: UIScrollView {
    private var originalFrame: CGRect?
    private var scrollView: ScrollView?
    
    let gestureDelegate = GestureDelegate()
    
    private let paddingX: CGFloat = 20 // Adjust the X-axis padding as needed
    private let paddingY: CGFloat = 20 // Adjust the Y-axis padding as needed
    private let cornerRadius: CGFloat = 40

    
    
    // Add a property observer to update the delegate's isOpen when FloatinItemView's isOpen changes.
    var isOpen: Bool = false {
        didSet {
            gestureDelegate.isOpen = isOpen
        }
    }
    var isExpanded: Bool = false {
        didSet {
            gestureDelegate.isExpanded = isExpanded
        }
    }
    
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
        layer.cornerRadius = cornerRadius
        
        // Add a pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        panGesture.delegate = gestureDelegate
        
        // Add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
        tapGesture.delegate = gestureDelegate
        
        // Add swipe gestures for up and down
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp(_:)))
        swipeUpGesture.direction = .up
        addGestureRecognizer(swipeUpGesture)
        swipeUpGesture.delegate = gestureDelegate
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown(_:)))
        swipeDownGesture.direction = .down
        addGestureRecognizer(swipeDownGesture)
        swipeUpGesture.delegate = gestureDelegate
        
        scrollView = ScrollView(frame: bounds)
        scrollView?.parentFloatingItemView = self
        addSubview(scrollView!)
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
        openView()
    }
    
    @objc private func handleSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        if !isOpen {
            return
        }
        
        closeView()
    }
    
    @objc private func handleSwipeUp(_ gesture: UISwipeGestureRecognizer) {
        if !isOpen {
            return
        }
        
        
        if !isExpanded {
            expandView()
            return
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

        UIView.animate(withDuration: 0.3, animations: {
            self.frame = newFrame
        }) { (_) in
            // This closure is called when the animation is complete.
            self.isOpen = true
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView!.frame = self.bounds
        })
        
        self.scrollView?.open(fullScreenBounds: innerBounds)
    }
    
    private func expandView() {
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height
        let innerBounds = UIScreen.main.bounds.inset(by: UIEdgeInsets(top: statusBarHeight!, left: 0, bottom: 0, right: 0))
        
        let newFrame = CGRect(
            x: 0,
            y: statusBarHeight!, // Add statusBarHeight to the Y coordinate
            width: innerBounds.width,
            height: innerBounds.height
        )
        
        layer.cornerRadius = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = newFrame
        }) { (_) in
            // This closure is called when the animation is complete.
            self.isExpanded = true
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView!.frame = self.bounds
        })
        
        self.scrollView?.expand()
    }
    
    func closeView() {
        print("Call close view")
        // If closed, animate the view back to the original size
        layer.cornerRadius = cornerRadius
        
        if let originalFrame = originalFrame {
            UIView.animate(withDuration: 0.3, animations: {
                self.frame = originalFrame
        }) { (_) in
            // This closure is called when the animation is complete.
            self.isOpen = false
            self.isExpanded = false
            }
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView!.frame = self.bounds
        })
        
        self.scrollView?.close()
    }
}
