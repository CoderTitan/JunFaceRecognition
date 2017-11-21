//
//  JunFaceRecognition.swift
//  JunFaceRecognition
//
//  Created by iOS_Tian on 2017/11/17.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit

class JunFaceRecognition: NSObject {

}

extension JunFaceRecognition {
    /// 通过人脸识别提取有效的人脸图片
    static func faceImagesByFaceRecognition(imageView: UIImageView, resultCallback: @escaping ((_ count: Int) -> ())) {
        //0. 删除子控件
        let subViews = imageView.subviews
        for subview in subViews {
            if subview.isKind(of: UIView.self) {
                subview.removeFromSuperview()
            }
        }
        
        //1. 创建上下文对象
        let context = CIContext()
        
        //2. UIImage转成CIImage
        guard let image = imageView.image  else { return }
        guard let ciImage = CIImage(image: image) else { return }
        
        //3. 参数设置(精度设置)
        let parmes = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        
        //4. 创建识别类
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: parmes)
        
        //5. 找到识别其中的人连对象
        guard let faceArr = detector?.features(in: ciImage) else { return }
        
        //6. 添加识别的红框
        let resultView = UIView(frame: CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.height))
        imageView.addSubview(resultView)
        
        //7. 遍历扫描结果
        for faceFeature in faceArr {
            let scale = getScale(imageView: imageView, image: image)
            let rect = CGRect(x: faceFeature.bounds.minX / scale, y: faceFeature.bounds.minY / scale, width: faceFeature.bounds.width / scale, height: faceFeature.bounds.height / scale)
            resultView.addSubview(addRedrectangleView(rect: rect))
            
            //7.1 如果识别到眼睛
            guard let feature = faceFeature as? CIFaceFeature else { return }
            //左眼
            if feature.hasLeftEyePosition {
                let leftView = addRedrectangleView(rect: CGRect(x: 0, y: 0, width: 5, height: 5))
                let position = CGPoint(x: feature.leftEyePosition.x / scale, y: feature.leftEyePosition.y / scale)
                leftView.center = position
                resultView.addSubview(leftView)
            }
            //右眼
            if feature.hasRightEyePosition {
                let rightView = addRedrectangleView(rect: CGRect(x: 0, y: 0, width: 5, height: 5))
                let position = CGPoint(x: feature.rightEyePosition.x / scale, y: feature.rightEyePosition.y / scale)
                rightView.setValue(position, forKey: "center")
                resultView.addSubview(rightView)
            }
            
            //7.2 识别嘴巴
            if feature.hasMouthPosition {
                let mouthView = addRedrectangleView(rect: CGRect(x: 0, y: 0, width: 20, height: 10))
                let position = CGPoint(x: feature.mouthPosition.x / scale, y: feature.mouthPosition.y / scale)
                mouthView.setValue(position, forKey: "center")
                resultView.addSubview(mouthView)
            }
        }
        
        //8. 将resultView沿x轴翻转
        resultView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        //9. 结果回调
        resultCallback(faceArr.count)
    }
    
    static func addRedrectangleView(rect: CGRect) -> UIView{
        let redView = UIView(frame: rect)
        redView.layer.borderColor = UIColor.red.cgColor
        redView.layer.borderWidth = 1
        return redView
    }
}

//图片和imageView的尺寸比例
extension JunFaceRecognition {
    static func getScale(imageView: UIImageView, image: UIImage) -> CGFloat{
        let viewSize = imageView.frame.size
        let imageSize = image.size
        
        let widthScale = imageSize.width / viewSize.width
        let heightScale = imageSize.height / viewSize.height
        
        return widthScale > heightScale ? widthScale : heightScale
    }
}
