//
//  SQProgressHUD.h
//
//  Created by ysq on 16/3/19.
//  Copyright © 2016年 ysq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SQProgressHUD : UIView

+ (instancetype)showHUDToView:(UIView *)view animated:(BOOL)animated;

+ (void)hideHUDToView:(UIView *)view animated:(BOOL)animated;


@end


@interface YSQCALayer : CALayer

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat lineWidth;


@end