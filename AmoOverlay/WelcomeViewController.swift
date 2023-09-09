//
//  WelcomeViewController.swift
//  AmoOverlay
//
//  Created by Benoit Cotte on 08/09/2023.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let _backgroundColor = UIColor(
            red: CGFloat(0) / 255.0,
            green: CGFloat(0) / 255.0,
            blue: CGFloat(0) / 255.0,
            alpha: 0
        )
        self.view.backgroundColor = _backgroundColor
        
        let floatinItemView = FloatinItemView(frame: CGRect(x: 100, y: 100, width: 80, height: 80))
        self.view.addSubview(floatinItemView)
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
