//
//  PictureViewController.swift
//  JunFaceRecognition
//
//  Created by iOS_Tian on 2017/11/17.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit

class PictureViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var faceNumLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "图片识别"
    }
    

    //选择照片
    @IBAction func chosePictureAction(_ sender: Any) {
        //1. 判断是否允许该操作
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            print("操作限制, 不可执行")
            return
        }
        
        //2. 创建照片选择器
        let imagePC = UIImagePickerController()
        //2.1 设置数据源
        imagePC.sourceType = .photoLibrary
        //2.2 设置代理
        imagePC.delegate = self
        //2.3 的弹出控制器
        present(imagePC, animated: true, completion: nil)
    }
    
    //开始识别照片
    @IBAction func recognitionAction(_ sender: Any) {
        JunFaceRecognition.faceImagesByFaceRecognition(imageView: imageView, resultCallback: { count in
            self.faceNumLabel.text = "人脸个数: \(count)个"
        })
    }
}

//MARK: 实现相册代理
extension PictureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 1. 获取选中的图片
        guard let selectorImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
        imageView.image = selectorImage
        
        //3. 退出控制器
        picker.dismiss(animated: true, completion: nil)
    }
    
    //选取完成后调用
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
