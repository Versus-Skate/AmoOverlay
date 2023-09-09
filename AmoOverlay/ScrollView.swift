
import UIKit

class GestureDelegateScroll: NSObject, UIGestureRecognizerDelegate {
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
            return false
        } else {
            // Allow both pan and tap gestures when the view is closed.
            return true
        }
    }
}


class ScrollView: UIScrollView {
    weak var parentFloatingItemView: FloatinItemView? // Reference to the parent floating item
    private let closeThreshold: CGFloat = 0.8 // Adjust the threshold as needed (0.8 means 80% of the page must be visible)
    private var currentPageIndex: Int = 0
    
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
        delegate = self
        
        backgroundColor = .yellow
        
        // Add your content pages here
        let pageWidth = frame.width
        let pageHeight = frame.height

        for i in 0..<3 { // Create 3 pages
            let pageFrame = CGRect(x: 0, y: CGFloat(i) * pageHeight, width: pageWidth, height: pageHeight)
            let pageView = UIView(frame: pageFrame)
            pageView.backgroundColor = UIColor(red: CGFloat(i) / 3.0, green: 0.5, blue: 0.8, alpha: 1.0) // Random background color for demonstration
            addSubview(pageView)
        }
        
        // Set the content size to accommodate all pages
        contentSize = CGSize(width: frame.width, height: frame.height * CGFloat(3))
    }
    
    func open() {
        
//        let newFrame = CGRect(
//            x: 0,
//            y: 0, // Add statusBarHeight to the Y coordinate
//            width: 1000,
//            height: 1000
//        )
//        
//        UIView.animate(withDuration: 0.3, animations: {
//            self.frame = newFrame
//            self.subviews[self.currentPageIndex].frame = newFrame
//        })
//        
//        let pageWidth = newFrame.width
//        let pageHeight = newFrame.height
//        
//        for i in 0..<3 { // Create 3 pages
//            let pageFrame = CGRect(x: 0, y: CGFloat(i) * pageHeight, width: pageWidth, height: pageHeight)
//            let pageView = UIView(frame: pageFrame)
//            pageView.backgroundColor = UIColor(red: CGFloat(i) / 3.0, green: 0.5, blue: 0.8, alpha: 1.0) // Random background color for demonstration
//            addSubview(pageView)
//        }
//        
//        self.contentSize = CGSize(width: newFrame.width, height: newFrame.height * CGFloat(3))
    }
    
    func expand() {
        isScrollEnabled = true
    }
    
    func close() {
        isScrollEnabled = false
    }
}

extension ScrollView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Calculate the current page index based on the content offset
        let pageHeight = frame.height
        let newPageIndex = Int(round(contentOffset.y / pageHeight))
        
        // Update the current page index
        currentPageIndex = newPageIndex
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if currentPageIndex == 2 && velocity.y > 0 {
            parentFloatingItemView?.closeView()
        }
    
        if currentPageIndex == 0 && velocity.y < 0 {
            parentFloatingItemView?.closeView()
        }
    }
}
