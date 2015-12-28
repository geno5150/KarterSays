//
//  ViewController.swift
//  KarterSays
//
//  Created by Geno Erickson on 12/15/15.
//  Copyright © 2015 SuctionPeach. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "HappyKarter" {
            if let RedVC = segue.destinationViewController as? RecorderViewController{
                RedVC.speed = 1500
                print("happy karter")
            }
        }else if segue.identifier == "GrumpyKarter"{
            if let RedVC = segue.destinationViewController as? RecorderViewController{
                RedVC.speed = -500
                print("grumpy karter")
                
            }
        }else{
            if let RedVC = segue.destinationViewController as? RecorderViewController{
                RedVC.speed = -200
                print("robot karter")
        }
    }
}
}