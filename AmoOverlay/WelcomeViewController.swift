//
//  WelcomeViewController.swift
//  AmoOverlay
//
//  Created by Benoit Cotte on 08/09/2023.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true

        let _backgroundColor = UIColor(
            red: CGFloat(0) / 255.0,
            green: CGFloat(0) / 255.0,
            blue: CGFloat(0) / 255.0,
            alpha: 0
        )
        self.view.backgroundColor = _backgroundColor
        
        let floatinItemView = FloatinItemView(frame: CGRect(x: 100, y: 100, width: 80, height: 80))
        self.view.addSubview(floatinItemView)
        
        let buttonView = CloseButton(frame: CGRect(
            x: CGFloat(UIScreen.main.bounds.width / 2) - 50 / 2,
            y: CGFloat(UIScreen.main.bounds.height) - 100,
            width: 50,
            height: 50
        ))
        buttonView.parentView = self.view
        buttonView.floatinItemView = floatinItemView
        self.view.addSubview(buttonView)
        
        floatinItemView.buttonView = buttonView
    }
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
