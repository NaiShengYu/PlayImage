//
//  ViewController.m
//  PlayImage
//
//  Created by Nasheng Yu on 2019/5/5.
//  Copyright © 2019 Nasheng Yu. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "FirstViewController.h"
#import <HealthKit/HealthKit.h>
#define imgSizeW 1536.0
#define imgSizeH 2048.0
#define kScreenBounds   [UIScreen mainScreen].bounds
#define kScreenWidth  kScreenBounds.size.width*1.0
#define kScreenHeight kScreenBounds.size.height*1.0
@interface ViewController ()
//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic)AVCaptureDevice *device;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic)AVCaptureDeviceInput *input;

//当启动摄像头开始捕获输入
@property(nonatomic)AVCaptureMetadataOutput *output;

@property (nonatomic)AVCaptureStillImageOutput *ImageOutPut;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic)AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic)UIButton *PhotoButton;
@property (nonatomic)UIButton *flashButton;
@property (nonatomic)UIImageView *imageView;
@property (nonatomic)UIView *focusView;
@property (nonatomic)BOOL isflashOn;
@property (nonatomic)UIImage *image;

@property (nonatomic)NSTimer *timer;
@property (nonatomic)UILabel *timeLab;
@property (nonatomic)UILabel *lab1;

@property (nonatomic)BOOL canCa;
@property (nonatomic)int num;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _num = 0;
    _canCa = [self canUserCamear];
    if (_canCa) {
        [self customCamera];
        [self customUI];
        
    }else{
        return;
    }
    
    UIImageView * imageV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"111"]];
    imageV.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    imageV.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imageV];
    
    for (int i = 0; i <8; i ++) {
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        imgView.tag = i+1000;
        [self.view addSubview:imgView];
    }
    
    CGFloat o =550*kScreenWidth/imgSizeW;
    CGFloat p =kScreenHeight-520*kScreenHeight/imgSizeH;
    CGFloat r =320*kScreenWidth/imgSizeW;
    CGFloat s =80*kScreenHeight/imgSizeH;
    NSLog(@"o=%f/np=%f/nr=%f/ns=%f",o,p,r,s);
    _lab1 = [[UILabel alloc]initWithFrame:CGRectMake(550*kScreenWidth/imgSizeW, kScreenHeight-520*kScreenHeight/imgSizeH, 320*kScreenWidth/imgSizeW, 80*kScreenHeight/imgSizeH)];
    _lab1.textColor = [UIColor whiteColor];
    _lab1.font = [UIFont fontWithName:@"Arial Rounded MT Bold"  size:100];
    _lab1.adjustsFontSizeToFitWidth = YES;
    _lab1.text = @"你向未来";
    [self.view addSubview:_lab1];
    
    _timeLab = [[UILabel alloc]initWithFrame:CGRectMake(550*kScreenWidth/imgSizeW, kScreenHeight-420*kScreenHeight/imgSizeH, 320*kScreenWidth/imgSizeW, 80*kScreenHeight/imgSizeH)];
    _timeLab.adjustsFontSizeToFitWidth = YES;
    _timeLab.textColor = [UIColor whiteColor];
    _timeLab.text = @"前进了0''";
    _timeLab.font = [UIFont fontWithName:@"Arial Rounded MT Bold"  size:100];
    
    
    [self.view addSubview:_timeLab];
  
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_timer invalidate];
    [self.session stopRunning];

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.session startRunning];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)customUI{
    _PhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _PhotoButton.center = CGPointMake(kScreenWidth/2-20, kScreenHeight-420*kScreenHeight/imgSizeH);
    _PhotoButton.bounds =CGRectMake(0, 0, 440*kScreenWidth/imgSizeW, 380*kScreenHeight/imgSizeH);
//    _PhotoButton.backgroundColor = [UIColor orangeColor];
    [_PhotoButton addTarget:self action:@selector(shutterCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_PhotoButton];
    
    _focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    _focusView.layer.borderWidth = 1.0;
    _focusView.layer.borderColor =[UIColor greenColor].CGColor;
    _focusView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_focusView];
    _focusView.hidden = YES;
    
//    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    leftButton.frame = CGRectMake(kScreenWidth*1/4.0-30, kScreenHeight-100, 60, 60);
//    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
//    leftButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [leftButton addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:leftButton];
//
//    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    rightButton.frame = CGRectMake(kScreenWidth*3/4.0-60, kScreenHeight-100, 60, 60);
//    [rightButton setTitle:@"切换" forState:UIControlStateNormal];
//    rightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [rightButton addTarget:self action:@selector(changeCamera) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:rightButton];
//
//    _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _flashButton.frame = CGRectMake(kScreenWidth-80, kScreenHeight-100, 80, 60);
//    [_flashButton setTitle:@"闪光灯关" forState:UIControlStateNormal];
//    [_flashButton addTarget:self action:@selector(FlashOn) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_flashButton];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}
- (void)customCamera{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //使用设备初始化输入
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    
    //生成输出对象
    self.output = [[AVCaptureMetadataOutput alloc]init];
    self.ImageOutPut = [[AVCaptureStillImageOutput alloc] init];
    
    //生成会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc]init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        
        self.session.sessionPreset = AVCaptureSessionPresetHigh;
        
    }
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.ImageOutPut]) {
        [self.session addOutput:self.ImageOutPut];
    }
    
    //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
//    self.previewLayer.position = CGPointMake(kScreenWidth/2, kScreenHeight/2);
//    self.previewLayer.bounds = CGRectMake(0, 0, kScreenWidth, kScreenWidth);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    
    //开始启动
    [self.session startRunning];
    if ([_device lockForConfiguration:nil]) {
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
}
- (void)FlashOn{
    if ([_device lockForConfiguration:nil]) {
        if (_isflashOn) {
            if ([_device isFlashModeSupported:AVCaptureFlashModeOff]) {
                [_device setFlashMode:AVCaptureFlashModeOff];
                _isflashOn = NO;
                [_flashButton setTitle:@"闪光灯关" forState:UIControlStateNormal];
            }
        }else{
            if ([_device isFlashModeSupported:AVCaptureFlashModeOn]) {
                [_device setFlashMode:AVCaptureFlashModeOn];
                _isflashOn = YES;
                [_flashButton setTitle:@"闪光灯开" forState:UIControlStateNormal];
            }
        }
        
        [_device unlockForConfiguration];
    }
}
- (void)changeCamera{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        
        CATransition *animation = [CATransition animation];
        
        animation.duration = .5f;
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        animation.type = @"oglFlip";
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
        }
        else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }
        
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:_input];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.input = newInput;
                
            } else {
                [self.session addInput:self.input];
            }
            
            [self.session commitConfiguration];
            
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
        
    }
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}
- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}
- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        _focusView.center = point;
        _focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                _focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                _focusView.hidden = YES;
            }];
        }];
    }
    
}
#pragma mark - 截取照片
- (void)shutterCamera
{
    [_timer invalidate];
    UIImage *img = [UIImage imageNamed:@"111"];
    UIImage *img1 = [UIImage imageNamed:@"444"];
    FirstViewController *firstVC = [[FirstViewController alloc]init];
//    UIImage *resultImg = [self composeImg:img Img:img];
//    UIImage *resultImg1 = [self composeImg1:img1 Img:img1];
//    firstVC.img = resultImg;
//    firstVC.img1 = resultImg1;
//    [self presentViewController:firstVC animated:YES completion:nil];
//
    AVCaptureConnection * videoConnection = [self.ImageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }

    [self.ImageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        self.image = [UIImage imageWithData:imageData];
        [self.session stopRunning];
        
        UIImage *resultImg = [self composeImg:self.image Img:img];
        UIImage *resultImg1 = [self composeImg1:self.image Img:img1];
        firstVC.img = resultImg;
        firstVC.img1 = resultImg1;
        [self presentViewController:firstVC animated:YES completion:nil];
        
//        [self saveImageToPhotoAlbum:self.image];
//        self.imageView = [[UIImageView alloc]initWithFrame:self.previewLayer.frame];
//        [self.view insertSubview:_imageView belowSubview:_PhotoButton];
//        self.imageView.layer.masksToBounds = YES;
//        self.imageView.image = _image;
//        NSLog(@"image size = %@",NSStringFromCGSize(self.image.size));
    }];
}
#pragma - 保存至相册
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
// 指定回调方法

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}
-(void)cancle{
    [self.imageView removeFromSuperview];
    [self.session startRunning];
}
#pragma mark - 检查相机权限
- (BOOL)canUserCamear{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请打开相机权限" message:@"设置-隐私-相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alertView.tag = 100;
        [alertView show];
        return NO;
    }
    else{
        return YES;
    }
    return YES;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0 && alertView.tag == 100) {
        
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            
            [[UIApplication sharedApplication] openURL:url];
            
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (UIImage *)screenshot
{
    CGSize imageSize = CGSizeZero;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


#pragma mark - 两张图合并成一张图
- (UIImage *)composeImg:(UIImage *)firstImage Img:(UIImage *)secondImage {

    CGFloat w = firstImage.size.width;
    CGFloat h = firstImage.size.height;
    
    
    //以firstImage的图大小为底图
    //以firstImage的图大小为画布创建上下文
    UIGraphicsBeginImageContext(CGSizeMake(w, h));
    [firstImage drawInRect:CGRectMake(0,0, w, h)];//先把拍的照片画出来

    [secondImage drawInRect:CGRectMake(0, 0, w, h)];//把框子画出来
    
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *datestr = [formatter stringFromDate:nowDate];
    CGFloat NumImageX = w*430/imgSizeW;
    CGFloat NumImageY = h*100/imgSizeH;
    CGFloat NumImageH = h*120/imgSizeH;
    CGFloat imgw = (660.0/imgSizeW*w)/datestr.length/1.0;

    CGFloat b = 0.0;
    for (int i =0; i <datestr.length; i ++) {
        NSString *numImgName =[datestr substringWithRange:NSMakeRange(i, 1)];
        UIImage *img = [UIImage imageNamed:numImgName];
        [img drawInRect:CGRectMake(NumImageX+b , NumImageY, imgw,NumImageH)];
        b += (imgw);
    }
   
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawPath(context, kCGPathStroke);
    [_lab1 drawTextInRect:CGRectMake(545/imgSizeW*w, h-520.0/imgSizeH*h, 300/imgSizeW*w, 90/imgSizeH*h)];
    [_timeLab drawTextInRect:CGRectMake(545/imgSizeW*w, h-400.0/imgSizeH*h, 300/imgSizeW*w, 90/imgSizeH*h)];

    //获得一个位图图形上下文
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();//从当前上下文中获得最终图片
    UIGraphicsEndImageContext();//关闭上下文
    return resultImg;
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *filePath = [path stringByAppendingPathComponent:@"01.png"];
//    [UIImagePNGRepresentation(resultImg) writeToFile:filePath atomically:YES];//保存图片到沙盒
//
//    CGImageRelease(imgRef);
//    CGImageRelease(imgRef1);
}

#pragma mark - 两张图合并成一张图
- (UIImage *)composeImg1:(UIImage *)firstImage Img:(UIImage *)secondImage {
    
    CGFloat w = firstImage.size.width;
    CGFloat h = firstImage.size.height;
    
    
    //以firstImage的图大小为底图
    //以firstImage的图大小为画布创建上下文
    UIGraphicsBeginImageContext(CGSizeMake(w, h));
    [firstImage drawInRect:CGRectMake(0,0, w, h)];//先把拍的照片画出来
    
    [secondImage drawInRect:CGRectMake(0, 0, w, h)];//把框子画出来
    
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *datestr = [formatter stringFromDate:nowDate];
    CGFloat NumImageX = w*310/1440.0;
    CGFloat NumImageY = h*130/2560.0;
    CGFloat NumImageH = h*140/2560.0;
    CGFloat imgw = (800/1440.0*w)/datestr.length/1.0;
    
    CGFloat b = 0.0;
    for (int i =0; i <datestr.length; i ++) {
        NSString *numImgName =[datestr substringWithRange:NSMakeRange(i, 1)];
        UIImage *img = [UIImage imageNamed:numImgName];
        [img drawInRect:CGRectMake(NumImageX+b , NumImageY, imgw,NumImageH)];
        b += (imgw);
    }
    //画文字
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawPath(context, kCGPathStroke);
    [_lab1 drawTextInRect:CGRectMake(480.0/1440.0*w, h-635.0/2560.0*h, 390/1440.0*w, 90/2560.0*h)];
    [_timeLab drawTextInRect:CGRectMake(480/1440.0*w, h-480.0/2560.0*h, 390/1440.0*w, 90/2560.0*h)];
    
//    [_lab1 drawTextInRect:CGRectMake(370, h-480, 300, 70)];
//    [_timeLab drawTextInRect:CGRectMake(370, h-380,300,70)];
    //获得一个位图图形上下文
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();//从当前上下文中获得最终图片
    UIGraphicsEndImageContext();//关闭上下文
    return resultImg;
    //    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    //    NSString *filePath = [path stringByAppendingPathComponent:@"01.png"];
    //    [UIImagePNGRepresentation(resultImg) writeToFile:filePath atomically:YES];//保存图片到沙盒
    //
    //    CGImageRelease(imgRef);
    //    CGImageRelease(imgRef1);
}


#pragma mark - 定时器修改时间
- (void)timeChange{
    
    _num +=1;
    int MM = _num/60;
    int ss = _num%60;
    if (MM >0) {
        _timeLab.text = [NSString stringWithFormat:@"前进了%d'%d''",MM,ss];
    }else
        _timeLab.text = [NSString stringWithFormat:@"前进了%d''",ss];

    
    
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *datestr = [formatter stringFromDate:nowDate];
    
    CGFloat NumImageX = kScreenWidth*430/imgSizeW;
    CGFloat NumImageY = kScreenHeight*100/imgSizeH;
    CGFloat NumImageH = kScreenHeight*120/imgSizeH;

    CGFloat b = 0.0;
    CGFloat imgw =(660.0/imgSizeW*kScreenWidth)/datestr.length/1.0;
    for (int i =0; i <datestr.length; i ++) {
        UIImageView *imgV = [self.view viewWithTag:i+1000];
        NSString *numImgName =[datestr substringWithRange:NSMakeRange(i, 1)];
        
        UIImage *img = [UIImage imageNamed:numImgName];
        imgV.image = img;
        imgV.frame =CGRectMake(NumImageX+b , NumImageY, imgw,NumImageH);
        b += (imgw);
    }
    
}

@end
