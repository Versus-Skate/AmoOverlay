//
//  FloatinItemView.swift
//  AmoOverlay
//
//  Created by Benoit Cotte on 08/09/2023.
//

import UIKit

import UIKit.UIGestureRecognizerSubclass

class ImmediatePanGestureRecognizer: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        // Start recognizing the pan gesture immediately upon touch down
        if state == .possible {
            state = .began
        }
    }
}

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
            return true
        }
    }
}

class FloatinItemView: UIScrollView {
    private var originalFrame: CGRect?
    private var scrollView: ScrollView?
    var buttonView: CloseButton?
    
    
    let gestureDelegate = GestureDelegate()
    var impactFeedback: UIImpactFeedbackGenerator?
    var impactFeedbackHeavy: UIImpactFeedbackGenerator?
    var impactFeedbackLight: UIImpactFeedbackGenerator?
    
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
        layer.cornerRadius = cornerRadius
        
        let _backgroundColor = UIColor(
            red: CGFloat(0) / 255.0,
            green: CGFloat(0) / 255.0,
            blue: CGFloat(0) / 255.0,
            alpha: 0
        )
        backgroundColor = _backgroundColor
        clipsToBounds = true // we will handle closing animations with this view cornerRadius -> we need to clips subview to bounds
        layer.masksToBounds = true // Ensures content inside is also clipped to the rounded corners
        
        // Add a pan gesture recognizer
        let panGesture = ImmediatePanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        panGesture.delegate = gestureDelegate
        
        // Add swipe gestures for up and down
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp(_:)))
        swipeUpGesture.direction = .up
        addGestureRecognizer(swipeUpGesture)
        swipeUpGesture.delegate = gestureDelegate
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown(_:)))
        swipeDownGesture.direction = .down
        addGestureRecognizer(swipeDownGesture)
        swipeUpGesture.delegate = gestureDelegate
        
        // Set scrollview to screen height and width => only this container will change size
        scrollView = ScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scrollView?.parentFloatingItemView = self
        addSubview(scrollView!)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        
        if isOpen {
            return
        }
        
        impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback?.prepare()
        impactFeedbackHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedbackHeavy?.prepare()
        impactFeedbackLight = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackLight?.prepare()
        
        switch gesture.state {
            
            case .began:
                UIView.animate(
                    withDuration: 0.4,
                    delay: 0,
                    usingSpringWithDamping: 0.3,
                    initialSpringVelocity: 0.2,
                    options: .curveEaseIn,
                    animations: {
                        self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    },
                    completion: nil
                )
            
                // Gesture started, create and prepare the feedback generator
                impactFeedback?.impactOccurred()

            case .changed:
                // Gesture is in progress
                let velocity = gesture.velocity(in: self.superview)
            
                if velocity.y > 500 {
                    impactFeedbackHeavy?.impactOccurred()
                } else if velocity.y > 300 {
                    impactFeedback?.impactOccurred()
                } else {
                    // Low velocity, use a light impact style
                    impactFeedbackLight?.impactOccurred()
                }
            

            case .ended:
                UIView.animate(
                    withDuration: 0.1,
                    delay: 0,
                    usingSpringWithDamping: 0.3,
                    initialSpringVelocity: 0.2,
                    options: .curveEaseOut,
                    animations: {
                        self.transform = .identity
                    },
                    completion: nil
                )
            
                let velocity = gesture.velocity(in: self.superview)
                if velocity == .zero {
                    impactFeedback?.impactOccurred()
                    openView()
                }
            
                // Gesture ended, clean up the feedback generator
                impactFeedback = nil
                impactFeedbackLight = nil
                impactFeedbackHeavy = nil
                moveToBounds()

            default:
                break
        }
        
        
        let translation = gesture.translation(in: self.superview)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        gesture.setTranslation(.zero, in: self.superview)
    }
    
    @objc private func handleSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        if !isOpen {
            return
        }
        
        // Create and prepare the feedback generator
        impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback?.prepare()

        // Trigger the impact feedback
        impactFeedback?.impactOccurred()

        // Clean up the feedback generator
        impactFeedback = nil
        
        closeView()
    }
    
    @objc private func handleSwipeUp(_ gesture: UISwipeGestureRecognizer) {
        if !isOpen {
            return
        }
        
        // Create and prepare the feedback generator
        impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback?.prepare()

        // Trigger the impact feedback
        impactFeedback?.impactOccurred()

        // Clean up the feedback generator
        impactFeedback = nil
        
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

        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: -0.1,
            options: .curveEaseIn,
            animations: {
                self.frame = newFrame
                self.layer.cornerRadius = self.cornerRadius / 2
            }
        ) { (_) in
            // This closure is called when the animation is complete.
            self.isOpen = true
        }
        
        self.scrollView?.open()
        self.buttonView?.show()
        
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
        
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.frame = newFrame
                self.layer.cornerRadius = 0
            }
        ) { (_) in
            // This closure is called when the animation is complete.
            self.isExpanded = true
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView!.frame = self.bounds
        })
        
        self.scrollView?.expand()
    }
    
    func closeView() {

        if let originalFrame = originalFrame {
            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0,
                options: .curveEaseIn,
                animations: {
                    self.frame = originalFrame
                    self.layer.cornerRadius = self.cornerRadius
                }
            ) { (_) in
                // This closure is called when the animation is complete.
                self.isOpen = false
                self.isExpanded = false
                self.scrollView?.close()
            }
        }
        
        self.buttonView?.hide()
    }
    
    private func moveToBounds() {
        var topBound: CGFloat
        var bottomBound: CGFloat
        var leftBound: CGFloat
        var rightBound: CGFloat
        
        let safeAreaInsets = window?.safeAreaInsets ?? .zero
        topBound = safeAreaInsets.top
        bottomBound = UIScreen.main.bounds.height - safeAreaInsets.bottom
        leftBound = safeAreaInsets.left
        rightBound = UIScreen.main.bounds.width - safeAreaInsets.right
        
        let duration: CGFloat = 0.2
        let damping: CGFloat = 0.6
        let initialSpringVelocity: CGFloat = 0
        
        
        if (self.frame.origin.x < leftBound) { // left
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: damping,
                initialSpringVelocity: initialSpringVelocity,
                options: .curveEaseIn,
                animations: {
                    self.frame.origin.x = leftBound
                },
                completion: nil
            )
        }
        if (self.frame.origin.x > rightBound - (originalFrame?.width ?? 80)) { // right
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: damping,
                initialSpringVelocity: initialSpringVelocity,
                options: .curveEaseIn,
                animations: {
                    self.frame.origin.x = rightBound - (self.originalFrame?.width ?? 80)
                },
                completion: nil
            )
        }
        
        if (self.frame.origin.y < topBound) { // up
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: damping,
                initialSpringVelocity: initialSpringVelocity,
                options: .curveEaseIn,
                animations: {
                    self.frame.origin.y = topBound
                },
                completion: nil
            )
        }
        
        if (self.frame.origin.y > bottomBound - (self.originalFrame?.height ?? 80)) { // bottom
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: damping,
                initialSpringVelocity: initialSpringVelocity,
                options: .curveEaseIn,
                animations: {
                    self.frame.origin.y = bottomBound - (self.originalFrame?.height ?? 80)
                },
                completion: nil
            )
        }
    }
}
