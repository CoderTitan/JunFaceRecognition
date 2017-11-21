//
//  ViewController.swift
//  JunFaceRecognition
//
//  Created by iOS_Tian on 2017/11/16.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "人脸识别"
    }

    //图片识别
    @IBAction func pictureAction(_ sender: Any) {
        navigationController?.pushViewController(PictureViewController(), animated: true)
    }
    
    //相机识别
    @IBAction func cameraAction(_ sender: Any) {
        navigationController?.pushViewController(CameraViewController(), animated: true)
    }
}

