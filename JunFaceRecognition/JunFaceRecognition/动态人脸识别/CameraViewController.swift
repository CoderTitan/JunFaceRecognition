//
//  CameraViewController.swift
//  JunFaceRecognition
//
//  Created by iOS_Tian on 2017/11/17.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit
import AVFoundation

//处理识别出来的人脸
protocol HandleMetadataOutputDelegate {
    func handleOutput(didDetect faceObjects: [AVMetadataObject], previewLayer: AVCaptureVideoPreviewLayer)
}

class CameraViewController: UIViewController {

    fileprivate var session = AVCaptureSession()
    fileprivate var deviceInput: AVCaptureDeviceInput?
    fileprivate var previewLayer = AVCaptureVideoPreviewLayer()
    @IBOutlet weak var previewView: JunPreviewView!
    var faceDelegate: HandleMetadataOutputDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addScaningVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //停止扫描
        session.stopRunning()
    }
}

extension CameraViewController {
    fileprivate func addScaningVideo(){
        //1.获取输入设备（摄像头）
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        //2.根据输入设备创建输入对象
        guard let deviceIn = try? AVCaptureDeviceInput(device: device) else { return }
        deviceInput = deviceIn
        
        //3.创建原数据的输出对象
        let metadataOutput = AVCaptureMetadataOutput()
        
        //4.设置代理监听输出对象输出的数据，在主线程中刷新
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        //4.2 设置输出代理
        faceDelegate = previewView
        
        //5.设置输出质量(高像素输出)
        session.sessionPreset = .high
        
        //6.添加输入和输出到会话
        if session.canAddInput(deviceInput!) {
            session.addInput(deviceInput!)
        }
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
        }
        
        //7.告诉输出对象要输出什么样的数据,识别人脸, 最多可识别10张人脸
        metadataOutput.metadataObjectTypes = [.face]
        
        //8.创建预览图层
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        previewView.layer.insertSublayer(previewLayer, at: 0)
        
        //9.设置有效扫描区域(默认整个屏幕区域)（每个取值0~1, 以屏幕右上角为坐标原点）
        metadataOutput.rectOfInterest = previewView.bounds
        
        //10. 开始扫描
        if !session.isRunning {
            DispatchQueue.global().async {
                self.session.startRunning()
            }
        }
    }
}


//MARK: 事件监听
extension CameraViewController {
    //拍照
    @IBAction func getPhotoAction(_ sender: Any) {
        
    }
    
    //切换摄像头
    @IBAction func switchCameraAction(_ sender: Any) {
        //1. 执行动画
        let anima = CATransition()
        anima.type = "oglFlip"
        anima.subtype = "fromLeft"
        anima.duration = 0.5
        view.layer.add(anima, forKey: nil)
        
        //2. 获取当前摄像头
        guard let deviceIn = deviceInput else { return }
        let position: AVCaptureDevice.Position = deviceIn.device.position == .back ? .front : .back
        
        //3. 创建新的input
        let deviceSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position)
        guard let newDevice = deviceSession.devices.filter({ $0.position == position }).first else { return }
        guard let newVideoInput = try? AVCaptureDeviceInput(device: newDevice) else { return }
        
        //4. 移除旧输入，添加新输入
        session.beginConfiguration()
        session.removeInput(deviceIn)
        session.addInput(newVideoInput)
        session.commitConfiguration()
        
        //5. 保存最新输入
        deviceInput = newVideoInput
    }
}


//MARK: AV代理
extension CameraViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for face in metadataObjects {
            let faceObj = face as? AVMetadataFaceObject
//            let faceID = faceObj?.faceID
//            let faceRollAngle = faceObj?.rollAngle
            print(faceObj!)
        }
        
        faceDelegate?.handleOutput(didDetect: metadataObjects, previewLayer: previewLayer)
    }
}



/*
 //获取实时图像，这个代理方法的回调频率很快，几乎与手机屏幕的刷新频率一样快
 func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
 //1. 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
 guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
 
 //2. 锁定pixel buffer的基地址
 CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
 
 //3. 得到pixel buffer的基地址
 let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
 
 //4. 得到pixel buffer的行字节数
 let bytesNum = CVPixelBufferGetBytesPerRow(imageBuffer)
 
 //5. 得到pixel buffer的宽和高
 let cvWidth = CVPixelBufferGetWidth(imageBuffer)
 let cvHeight = CVPixelBufferGetHeight(imageBuffer)
 
 //6. 创建一个依赖于设备的RGB颜色空间
 let colorSpace = CGColorSpaceCreateDeviceRGB()
 
 //7. 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
 guard let context = CGContext(data: baseAddress, width: cvWidth, height: cvHeight, bitsPerComponent: 8, bytesPerRow: bytesNum, space: colorSpace, bitmapInfo: UInt32(0)) else { return }
 
 //8. 根据这个位图context中的像素数据创建一个Quartz image对象
 let quartzImage = context.makeImage()
 
 //9. 解锁pixel buffer
 CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
 }

 */
