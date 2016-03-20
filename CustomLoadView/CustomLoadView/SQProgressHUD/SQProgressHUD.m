//
//  SQProgressHUD.m
//
//  Created by ysq on 16/3/19.
//  Copyright © 2016年 ysq. All rights reserved.
//

#import "SQProgressHUD.h"

static NSString *const key_animation = @"key_animation";
static CGFloat const cornerRadius = 6;
static CGFloat const backViewWidth = 60;
static CGFloat const backViewHeight = 60;
static CGFloat const duration = 0.3;
static CGFloat const lineWidth = 6;


@interface YSQCALayer ()

@end



@implementation YSQCALayer

@dynamic lineWidth;
@dynamic color;

//改变layer的属性就会调用重绘的方法
+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"color"]) {
        return YES;
    } else if ([key isEqualToString:@"lineWidth"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat radius = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) /2 - self.lineWidth;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    //radius 半径 angle 角度 clockwise:顺时针
    [path addArcWithCenter:center radius:radius startAngle: -M_PI_2 endAngle:(M_PI * 2) * .5 - M_PI_2 clockwise:YES];
    CGContextAddPath(ctx, path.CGPath);
    CGContextSetLineWidth(ctx, self.lineWidth);
    CGContextSetStrokeColorWithColor(ctx, self.color.CGColor);
    CGContextStrokePath(ctx);
}

@end


@interface SQProgressHUD ()

@property (nonatomic, strong) YSQCALayer *ysqLayer;
@property (nonatomic , strong) CAShapeLayer *textLayer;
@property (nonatomic, strong) UIView *backView;

@end


@implementation SQProgressHUD

+ (instancetype)showHUDtoView:(UIView *)view animated:(BOOL)animated {
    SQProgressHUD *load = [[SQProgressHUD alloc]initWithView:view];
    [view addSubview:load];
    [load startAnimation:animated];
    return load;
}


- (instancetype)initWithView:(UIView *)view{
    NSAssert(view, @"View must not be nil");
    return [self initWithFrame:view.bounds];
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createBackView];
        [self createLayer];
    }
    return self;
}

- (void)createBackView {
    self.backView = [[UIView alloc]initWithFrame:CGRectMake((self.frame.size.width - backViewWidth) / 2, (self.frame.size.height - backViewHeight) / 2, backViewWidth, backViewHeight)];
    self.backView.layer.cornerRadius = cornerRadius;
    self.backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
    self.backView.hidden = YES;
    [self addSubview:self.backView];
}

- (void)createLayer {
    self.ysqLayer = [YSQCALayer layer];
    self.ysqLayer.contentsScale = [UIScreen mainScreen].scale;
    self.ysqLayer.color = [UIColor redColor];
    self.ysqLayer.lineWidth = lineWidth;
    self.ysqLayer.bounds = self.backView.bounds;
    self.ysqLayer.position = CGPointMake(CGRectGetMidX(self.backView.bounds), CGRectGetMidY(self.backView.bounds));
    [self.backView.layer addSublayer:self.ysqLayer];
}

- (void)startAnimation:(BOOL)animated {
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotateAnimation.fromValue = @(2*M_PI);
    rotateAnimation.toValue = @0;
    rotateAnimation.duration = duration;
    rotateAnimation.repeatCount = HUGE;
    rotateAnimation.removedOnCompletion = NO;
    [self.ysqLayer addAnimation:rotateAnimation forKey:key_animation];
    [self show:animated];
}


+ (void)hideHUDtoView:(UIView *)view animated:(BOOL)animated {
    SQProgressHUD *hud = [self HUDForView:view];
    if (hud != nil) {
        [hud hide:animated];
    }
}

+ (NSUInteger)hideAllHUDsToView:(UIView *)view animated:(BOOL)animated {
    NSArray *huds = [SQProgressHUD allHUDsForView:view];
    for (SQProgressHUD *hud in huds) {
        [hud hide:animated];
    }
    return [huds count];
}

+ (instancetype)HUDForView:(UIView *)view {
    //枚举
    NSEnumerator *subviewsEnum = [view.subviews objectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            return (SQProgressHUD *)subview;
        }
    }
    return nil;
}

+ (NSArray *)allHUDsForView:(UIView *)view {
    NSMutableArray *huds = [NSMutableArray array];
    NSArray *subviews = view.subviews;
    for (UIView *HUDview in subviews) {
        if ([HUDview isKindOfClass:self ]) {
            [huds addObject:HUDview];
        }
    }
    return [huds copy];
}

- (void)show:(BOOL)animated {
    NSAssert([NSThread isMainThread], @"MBProgressHUD needs to be accessed on the main thread.");
    self.backView.hidden = NO;
    if (animated) {
        // CGAffineTransform CGAffineTransformScale(CGAffineTransform t,CGFloat sx, CGFloat sy)
        //第一个参数transform类型,第二个x的比例,第三个参数y的比例
        self.backView.transform = CGAffineTransformScale(self.transform,0.1,0.1);
        [UIView animateWithDuration:duration animations:^{
            self.backView.transform = CGAffineTransformScale(self.transform,1.2,1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration animations:^{
                self.backView.transform = CGAffineTransformIdentity;
            }];
        }];
    }
}

- (void)hide:(BOOL)animated {
    NSAssert([NSThread isMainThread], @"SQProgressHUD needs to be accessed on the main thread.");
    if (animated) {
        [UIView animateWithDuration:duration animations:^{
            self.backView.transform = CGAffineTransformScale(self.transform,1.2,1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration animations:^{
                self.backView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration animations:^{
                    self.backView.transform = CGAffineTransformScale(self.transform, 0.1, 0.1);
                } completion:^(BOOL finished) {
                    [self removeFromSuperview];
                }];
            }];
        }];
    } else {
        [self removeFromSuperview];
    }
}


@end







