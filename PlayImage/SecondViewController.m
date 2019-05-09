//
//  SecondViewController.m
//  PlayImage
//
//  Created by Nasheng Yu on 2019/5/9.
//  Copyright © 2019 Nasheng Yu. All rights reserved.
//

#import "SecondViewController.h"
#import "ViewController.h"
#define imgSizeW 1536.0
#define imgSizeH 2048.0
#define WS(blockSelf) __weak __typeof(&*self)blockSelf = self;
#define kScreenBounds   [UIScreen mainScreen].bounds
#define kScreenWidth  kScreenBounds.size.width*1.0
#define kScreenHeight kScreenBounds.size.height*1.0
@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView * imageV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"333"]];
    imageV.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    imageV.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imageV];
    
    
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.center = CGPointMake(kScreenWidth/2, kScreenHeight-430*kScreenHeight/imgSizeH);
    but.bounds =CGRectMake(0, 0, 750*kScreenWidth/imgSizeW, 180*kScreenHeight/imgSizeH);
    [but addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but];

}


- (void)takePhoto{
    
    [self presentViewController:[[ViewController alloc]init] animated:YES completion:nil];
    
    
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
