//
//  FirstViewController.h
//  PlayImage
//
//  Created by Nasheng Yu on 2019/5/5.
//  Copyright © 2019 Nasheng Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface FirstViewController : UIViewController
@property(nonatomic,strong)UIImage *img;
@property(nonatomic,strong)UIImage *img1;
@property(nonatomic,weak)ViewController *VC;



@end

NS_ASSUME_NONNULL_END
