//
//  SecondViewController.m
//  PlayImage
//
//  Created by Nasheng Yu on 2019/5/9.
//  Copyright © 2019 Nasheng Yu. All rights reserved.
//

#import "SecondViewController.h"
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#define imgSizeW 1536.0
#define imgSizeH 2048.0
#define WS(blockSelf) __weak __typeof(&*self)blockSelf = self;
#define kScreenBounds   [UIScreen mainScreen].bounds
#define kScreenWidth  kScreenBounds.size.width*1.0
#define kScreenHeight kScreenBounds.size.height*1.0
@interface SecondViewController ()
@property (nonatomic ,strong) AVPlayer *player;
@property (nonatomic ,strong) AVPlayerItem *playerItem;
@property (nonatomic,strong)AVPlayerLayer *playerLayer;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString * path = [[NSBundle mainBundle] pathForResource:@"HOME0511BB.mp4" ofType:nil];
    NSURL * videoUrl = [NSURL fileURLWithPath:path];

    //3.根据url创建播放器(player本身不能显示视频)
    self.player = [AVPlayer playerWithURL:videoUrl];
    
    //4.根据播放器创建一个视图播放的图层
    AVPlayerLayer * layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    //5.设置图层的大小
    layer.frame = self.view.bounds;
    
    //6.添加到控制器的view的图层上面
    [self.view.layer addSublayer:layer];
    
    //7.开始播放
    [self.player play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(play) name:@"playVideo" object:nil];

  
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.center = CGPointMake(kScreenWidth/2, kScreenHeight-430*kScreenHeight/imgSizeH);
    but.bounds =CGRectMake(0, 0, 750*kScreenWidth/imgSizeW, 180*kScreenHeight/imgSizeH);
//    but.backgroundColor = [UIColor orangeColor];
    [but addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_player play];
}

-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    // 播放完成后重复播放
    // 跳到最新的时间点开始播放
    [_player seekToTime:CMTimeMake(0, 1)];
    [_player play];
}

- (void)play{
    
    [_player play];

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
