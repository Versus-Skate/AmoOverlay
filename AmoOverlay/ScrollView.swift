
import UIKit

class GestureDelegateScroll: NSObject, UIGestureRecognizerDelegate {
    var isOpen: Bool = false // Shared open/closed state
    var isExpanded: Bool = false // Shared open/closed state

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if isOpen {
            return false
        } else {
            return true
        }
    }
}


let PAGES = [
    UIColor(red: CGFloat(0) / 3.0, green: 0.5, blue: 0.8, alpha: 1.0),
    UIColor(red: CGFloat(1) / 3.0, green: 0.5, blue: 0.8, alpha: 1.0),
    UIColor(red: CGFloat(2) / 3.0, green: 0.5, blue: 0.8, alpha: 1.0)
]


class ScrollView: UIScrollView {
    weak var parentFloatingItemView: FloatinItemView? // Reference to the parent floating item
    private let closeThreshold: CGFloat = 0.8 // Adjust the threshold as needed (0.8 means 80% of the page must be visible)
    private var currentPageIndex: Int = 0
    
    var impactFeedback: UIImpactFeedbackGenerator?
    
    let gestureDelegate = GestureDelegateScroll()
    
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
        isScrollEnabled = false
        isPagingEnabled = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        delegate = self
        
        let _backgroundColor = UIColor(
            red: CGFloat(0) / 255.0,
            green: CGFloat(0) / 255.0,
            blue: CGFloat(0) / 255.0,
            alpha: 1
        )
        
        backgroundColor = _backgroundColor
        
        // Add your content pages here
        let pageWidth = frame.width
        let pageHeight = frame.height

        for i in 0..<PAGES.count  { // Create 3 pages
            let pageFrame = CGRect(x: 0, y: CGFloat(i) * pageHeight, width: pageWidth, height: pageHeight)
            let pageView = UIView(frame: pageFrame)
            pageView.backgroundColor = PAGES[i]
            pageView.layer.cornerRadius = 0
            addSubview(pageView)
        }
        
        // Set the content size to accommodate all pages
        contentSize = CGSize(width: frame.width, height: frame.height * CGFloat(3))
    }
    
    func open(fullScreenBounds: CGRect) {
        for i in 0..<PAGES.count { // Update pages
            let pageY = CGFloat(i) * fullScreenBounds.height // Calculate the Y position for each page
            subviews[i].frame = CGRect(x: 0, y: pageY, width: fullScreenBounds.width, height: fullScreenBounds.height)
            subviews[i].layer.cornerRadius = 0
        }
        
        contentSize = CGSize(width: fullScreenBounds.width, height: fullScreenBounds.height * CGFloat(PAGES.count))
    }
    
    func expand() {
        isScrollEnabled = true
    }
    
    func close() {
        isScrollEnabled = false
    }
    
    func updateCurrentIndex() {
        let pageHeight = frame.height
        let newPageIndex = Int(round(contentOffset.y / pageHeight))
        currentPageIndex = newPageIndex
    }
    
    func updateCornerRadius() {
        let scrollOffset = contentOffset.y
        let maxCornerRadius: CGFloat = 20.0

        if currentPageIndex == 0 && scrollOffset < 0 {
            let cornerRadius = min(maxCornerRadius, abs(scrollOffset))
            subviews[0].layer.cornerRadius = cornerRadius
        } else if currentPageIndex == (PAGES.count - 1) && scrollOffset > CGFloat(PAGES.count - 1) * frame.height {
            let cornerRadius = min(maxCornerRadius, abs(scrollOffset - CGFloat(PAGES.count - 1) * frame.height))
            
            subviews[currentPageIndex].layer.cornerRadius = cornerRadius
        }
    }
    
    
}

extension ScrollView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Create and prepare the feedback generator
        impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback?.prepare()

        // Trigger the impact feedback
        impactFeedback?.impactOccurred()

        // Clean up the feedback generator
        impactFeedback = nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCurrentIndex()
        updateCornerRadius()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if currentPageIndex == 0 && velocity.y < 0 {
            parentFloatingItemView?.closeView()
        }
        
        if currentPageIndex == PAGES.count - 1 && velocity.y > 0 {
            parentFloatingItemView?.closeView()
        }

    }

}


