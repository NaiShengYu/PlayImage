

//
//  FirstViewController.m
//  PlayImage
//
//  Created by Nasheng Yu on 2019/5/5.
//  Copyright © 2019 Nasheng Yu. All rights reserved.
//

#import "FirstViewController.h"
#import <AFNetworking.h>
#define imgSizeW 1536.0
#define imgSizeH 2048.0
#define WS(blockSelf) __weak __typeof(&*self)blockSelf = self;
#define kScreenBounds   [UIScreen mainScreen].bounds
#define kScreenWidth  kScreenBounds.size.width*1.0
#define kScreenHeight kScreenBounds.size.height*1.0
@interface FirstViewController ()

@property (nonatomic,strong)UIImageView *QRCoreImageV;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView * imageV = [[UIImageView alloc]initWithImage:self.img];
    imageV.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    imageV.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imageV];
    
    UIImageView * imageV1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"222"]];
    imageV1.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    imageV1.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imageV1];
    
    
    UIButton *but =[[UIButton alloc]initWithFrame:CGRectMake( kScreenWidth-465.0*kScreenWidth/imgSizeW, kScreenHeight-540*kScreenHeight/imgSizeH, 390*kScreenWidth/imgSizeW, 105*kScreenHeight/imgSizeH)];
    [but addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but];
    
    UIButton *but1 =[[UIButton alloc]initWithFrame:CGRectMake( kScreenWidth-465.0*kScreenWidth/imgSizeW, kScreenHeight-410*kScreenHeight/imgSizeH, 390*kScreenWidth/imgSizeW, 105*kScreenHeight/imgSizeH)];
    [but1 addTarget:self action:@selector(upImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but1];
    
    _QRCoreImageV = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-376.0*kScreenWidth/imgSizeW, kScreenHeight-(852)*kScreenHeight/imgSizeH, 220*kScreenWidth/imgSizeW, 220*kScreenWidth/imgSizeW)];
    [self.view addSubview:_QRCoreImageV];
    
    
    
}

- (void)upImage{

    if (self.QRCoreImageV.image !=nil) {
        return;
    }
    
    WS(blockSelf);
    NSString *url = @"http://f.jianxinnet.com/cmj/api.php";
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:@"img_upload" forKey:@"app"];
    [param setObject:@"img" forKey:@"img"];

    NSData *data =UIImageJPEGRepresentation(self.img, 1);

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer =[AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    [manager POST:url parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
          NSString *filename =[NSString stringWithFormat:@"1111.jpeg"];
          [formData appendPartWithFileData:data name:@"img" fileName:filename mimeType:@"image/jpeg"];

    } progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *str =[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"str=%@",str);
        NSData *resData = [[NSData alloc] initWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingAllowFragments error:nil];
        
        self.QRCoreImageV.image = [self createQRCodeWithData:resultDic[@"data"] logoImage:nil imageSize:500];

        

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

    }];
}





- (void)back{
    
    [self dismissViewControllerAnimated:YES completion:nil];    
}

//之后只需要实例化一个CIFilter的对象, 给该对象添加数据后生成二维码即可
- (UIImage *)createQRCodeWithData:(NSString *)dataString logoImage:(UIImage *)logoImage imageSize:(CGFloat)size
{
    // 1. 创建一个二维码滤镜实例(CIFilter)
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 滤镜恢复默认设置
    [filter setDefaults];
    
    // 2. 给滤镜添加数据
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    // 使用KVC的方式给filter赋值
    [filter setValue:data forKeyPath:@"inputMessage"];
    
    // 3. 生成二维码
    CIImage *codeImage = [filter outputImage];
    
    return [self QRCodeUIImageFormCIImage:codeImage logoImage:logoImage withSize:size];
}
- (UIImage *)QRCodeUIImageFormCIImage:(CIImage *)image logoImage:(UIImage *)logoImage withSize:(CGFloat)size
{
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    UIImage *newCodeImage = [UIImage imageWithCGImage:scaledImage];
    UIImageWriteToSavedPhotosAlbum(newCodeImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    return newCodeImage;
//    return [self addImage:newCodeImage logo:self.img];
}
/**
 在一张图片上添加logo或者水印；
 warn 不支持jpg的图片
 
 @param image 原始的图片
 @param logoImage 要添加的logo
 @return 返回一张新的图片
 */
-(UIImage *)addImage:(UIImage *)image logo:(UIImage *)logoImage
{
    if (logoImage == nil)
    {
        return image;
    }
    //原始图片的宽和高，可以根据需求自己定义
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    //logo的宽和高，也可以根据需求自己定义
    CGFloat logoWidth = w *0.3;
    CGFloat logoHeight = logoWidth*logoImage.size.height/logoImage.size.width/1.0;
    //绘制
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 444 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), image.CGImage);
    //绘制的logo位置,可自己调整
    CGContextDrawImage(context, CGRectMake((w - logoWidth)/2,(h - logoHeight)/2, logoWidth, logoHeight), [logoImage CGImage]);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithCGImage:imageMasked], self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    return [UIImage imageWithCGImage:imageMasked];
}
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

@end
