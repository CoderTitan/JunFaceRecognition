//
//  JunPreviewView.swift
//  JunFaceRecognition
//
//  Created by iOS_Tian on 2017/11/18.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit
import AVFoundation

class JunPreviewView: UIView {
    fileprivate var overLayer = CALayer()
    /// 存放每一张脸的字典[faceID: id]
    fileprivate var faceLayers = [String: Any]()
    fileprivate var previewLayer = AVCaptureVideoPreviewLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    fileprivate func setupViews(){
        frame.size.height = UIScreen.main.bounds.height - 64 - 50
        backgroundColor = UIColor.black
        
        overLayer.frame = frame
        overLayer.sublayerTransform = CATransform3DMakePerspective(eyePosition: 1000)
        layer.addSublayer(overLayer)
    }
}

extension JunPreviewView: HandleMetadataOutputDelegate{
    func handleOutput(didDetect faceObjects: [AVMetadataObject], previewLayer: AVCaptureVideoPreviewLayer) {
        self.previewLayer = previewLayer
        
        //1. 获取本地数组
        let transformFaces = transformedFaces(faceObjs: faceObjects)
        
        //2. 拷贝一份所有人脸faceID字典
        var lostFaces = [String]()
        for faceID in faceLayers.keys {
            lostFaces.append(faceID)
        }

        //3. 遍历所有的face
        for i in 0..<transformFaces.count {
            guard let face = transformFaces[i] as? AVMetadataFaceObject  else { return }
            //3.1 判断是否包含该faceID
            if lostFaces.contains("\(face.faceID)"){
                lostFaces.remove(at: i)
            }
            
            //3.2 获取图层
            var faceLayer = faceLayers["\(face.faceID)"] as? CALayer
            if faceLayer == nil{
                //创建图层
                faceLayer = creatFaceLayer()
                overLayer.addSublayer(faceLayer!)
                //添加到字典中
                faceLayers["\(face.faceID)"] = faceLayer
            }
            
            //3.3 设置layer属性
            faceLayer?.transform = CATransform3DIdentity
            faceLayer?.frame = face.bounds
            
            //3.4 设置偏转角(左右摇头)
            if face.hasYawAngle{
                let tranform3D = transformDegress(yawAngle: face.yawAngle)
                
                //矩阵处理
                faceLayer?.transform = CATransform3DConcat(faceLayer!.transform, tranform3D)
            }
            
            //3.5 设置倾斜角,侧倾角(左右歪头)
            if face.hasRollAngle{
                let tranform3D = transformDegress(rollAngle: face.rollAngle)
                
                //矩阵处理
                faceLayer?.transform = CATransform3DConcat(faceLayer!.transform, tranform3D)
            }
            
            //3.6 移除消失的layer
            for faceIDStr in lostFaces{
                let faceIDLayer = faceLayers[faceIDStr] as? CALayer
                faceIDLayer?.removeFromSuperlayer()
                faceLayers.removeValue(forKey: faceIDStr)
            }
        }
    }
}


//MARK: 距离和偏转角计算
extension JunPreviewView{
    //返回的人脸数组处理
    fileprivate func transformedFaces(faceObjs: [AVMetadataObject]) -> [AVMetadataObject] {
        var faceArr = [AVMetadataObject]()
        for face in faceObjs {
            if let transFace = previewLayer.transformedMetadataObject(for: face){
                faceArr.append(transFace)
            }
        }
        return faceArr
    }
    
    //创建图层
    fileprivate func creatFaceLayer() -> CALayer{
        let layer = CALayer()
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 3
        //添加layer内容物
//        layer.contents = UIImage(named: "")?.cgImage
        return layer
    }
    
    //处理偏转角问题
    fileprivate func transformDegress(yawAngle: CGFloat) -> CATransform3D {
        let yaw = degreesToRadians(degress: yawAngle)
        //围绕Y轴旋转
        let yawTran = CATransform3DMakeRotation(yaw, 0, -1, 0)
        //设备旋转问题
        return CATransform3DConcat(yawTran, CATransform3DIdentity)
    }
    
    //处理倾斜角问题
    fileprivate func transformDegress(rollAngle: CGFloat) -> CATransform3D {
        let roll = degreesToRadians(degress: rollAngle)
        //围绕Z轴旋转
        return CATransform3DMakeRotation(roll, 0, 0, 1)
    }
    
    //角度转换
    fileprivate func degreesToRadians(degress: CGFloat) -> CGFloat{
        return degress * CGFloat(Double.pi) / 180
    }
    
    //眼睛到物体的距离
    fileprivate func CATransform3DMakePerspective(eyePosition: CGFloat) -> CATransform3D {
        var transform = CATransform3DIdentity
        //m34: 透视效果; 近大远小
        transform.m34 = -1 / eyePosition
        return transform
    }
}
