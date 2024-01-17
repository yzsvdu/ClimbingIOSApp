//
//  RouteStepViewController.swift
//  ClimbingAppIOSView
//
//  Created by Vincent Duong on 1/17/24.
//

import UIKit

class SelectStartHoldStepViewController: UIViewController {
    
    var poseDTO: PoseDTO?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Pose Data:")
        
        if let poseDTO {
            for (key, value) in poseDTO.attributes {
                print("\(key): \(value)")
            }
        }
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
