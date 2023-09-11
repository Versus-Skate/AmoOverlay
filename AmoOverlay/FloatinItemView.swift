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
                let velocity = gesture.velocity(in: self.superview)
                let translation = gesture.translation(in: self.superview)
                
                // Add small delay on drag
                let animationDuration: TimeInterval = 0.5
                let delayDuration: TimeInterval = 0
                let damping: CGFloat = 0.4

                // Calculate the final center position based on the translation
                let finalCenter = CGPoint(x: center.x + translation.x, y: center.y + translation.y)

                gesture.setTranslation(.zero, in: self.superview)
                UIView.animate(
                    withDuration: animationDuration,
                    delay: delayDuration,
                    usingSpringWithDamping: damping,
                    initialSpringVelocity: 1,
                    options: .curveEaseOut,
                    animations: {
                        self.center = finalCenter
                    },
                    completion: { _ in
                        gesture.setTranslation(.zero, in: self.superview)
                        // Animation completion code (if needed)
                    }
                )
        
                // Add haptic
                if abs(velocity.y) > 500 {
                    impactFeedbackHeavy?.impactOccurred()
                } else if abs(velocity.y) > 300 {
                    impactFeedback?.impactOccurred()
                } else {
                    impactFeedbackLight?.impactOccurred()
                }
            

            case .ended:
                // Calculate the desired final position based on the current position, gesture's velocity, and screen bounds
                let velocity = gesture.velocity(in: self.superview)
                var finalCenter = center
            
                // Calculate the magnitude (speed) of the velocity vector
                let speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y) // bounded to 1913
            
                let animationDuration = computeAnimationDuration(speed: speed)
                
                finalCenter.x = computeTargetX(velocity: gesture.velocity(in: self.superview), currentCenter: finalCenter)
                finalCenter.y = computeTargetY(velocity: gesture.velocity(in: self.superview), currentCenter: finalCenter, animationDuration: animationDuration)
            
            
                let damping = computeDamping(speed: speed)
                let initialVelocity = computeInitialVelocity(velocity: velocity, animationDuration: animationDuration)

                // Animate the view to the desired final position
                UIView.animate(
                    withDuration: animationDuration,
                    delay: 0,
                    usingSpringWithDamping: damping,
                    initialSpringVelocity: sqrt(initialVelocity.dy * initialVelocity.dy + initialVelocity.dx * initialVelocity.dx),
                    options: .curveEaseInOut,
                    animations: {
                        self.center = finalCenter
                    },
                    completion:  { _ in
                        gesture.setTranslation(.zero, in: self.superview)
                        // Animation completion code (if needed)
                    }
                )
            
            
                // Reset shape
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
            
                // Open card
                if velocity == .zero {
                    impactFeedback?.impactOccurred()
                    openView()
                }
            
                // Gesture ended, clean up the feedback generator
                impactFeedback = nil
                impactFeedbackLight = nil
                impactFeedbackHeavy = nil
                 
            
            default:
                break
        }
        
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
        let initialBackground = backgroundColor

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
                self.scrollView?.backgroundColor = initialBackground
            }
        }
        self.scrollView?.close()
        
        self.buttonView?.hide()
    }
    
    private func computeTargetX(velocity: CGPoint, currentCenter: CGPoint) -> CGFloat {
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height
        let screenBounds = UIScreen.main.bounds.inset(by: UIEdgeInsets(top: statusBarHeight!, left: 0, bottom: 0, right: 0))
        
        // Stick to a side on the x
        if velocity.x > 0 {
            let maxX = screenBounds.maxX - frame.width / 2
            return maxX
        } else {
            let minX = screenBounds.minX + frame.width / 2
            return minX
        }
    }
    
    private func computeTargetY(velocity: CGPoint, currentCenter: CGPoint, animationDuration: CGFloat) -> CGFloat {
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height
        let screenBounds = UIScreen.main.bounds.inset(by: UIEdgeInsets(top: statusBarHeight!, left: 0, bottom: 0, right: 0))
        
        if velocity.y > 0 { // goes down
            let maxY = screenBounds.maxY - frame.width / 2
            let projectedY = currentCenter.y + velocity.y * animationDuration * (screenBounds.width - currentCenter.x) / screenBounds.width
            return min(projectedY, maxY)
            
        } else { // goes up
            let minY = screenBounds.minY + frame.width / 2
            let projectedY = currentCenter.y + velocity.y * animationDuration  * (screenBounds.width - currentCenter.x) / screenBounds.width
            return max(projectedY, minY)
        }
    }
    
    private func computeDamping(speed: CGFloat) -> CGFloat {
        let minDamping: CGFloat = 0.3 // Minimum damping for realistic bounce
        let maxDamping: CGFloat = 0.5 // Maximum damping for minimal bounce
        let dampingRange = maxDamping - minDamping
        let damping = max(minDamping, min(maxDamping, 1.0 - speed / 2000.0 * dampingRange))
        return damping
    }
    
    private func computeInitialVelocity(velocity: CGPoint, animationDuration: CGFloat) -> CGVector {
        let initialVelocity = CGVector(dx: velocity.x * animationDuration / UIScreen.main.bounds.width, dy: velocity.y * animationDuration / UIScreen.main.bounds.height)
        return initialVelocity
    }
    
    private func computeAnimationDuration(speed: CGFloat) -> CGFloat {
        let minDuration: CGFloat = 0.3 // Minimum animation duration
        let maxDuration: CGFloat = 0.6 // Maximum animation duration
        let durationRange = maxDuration - minDuration
        let animationDuration = max(minDuration, min(maxDuration, Double(speed / 2000.0 * durationRange)))
        return animationDuration
    }
}


