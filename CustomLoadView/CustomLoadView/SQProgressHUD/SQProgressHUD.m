//
//  SQProgressHUD.m
//
//  Created by ysq on 16/3/19.
//  Copyright © 2016年 ysq. All rights reserved.
//

#import "SQProgressHUD.h"

#define TEXT_FONT  [UIFont boldSystemFontOfSize:12]


static NSString *const key_animation = @"key_animation";
static CGFloat const cornerRadius = 6;
static CGFloat const backViewWidth = 80;
static CGFloat const backViewHeight = 80;
static CGFloat const duration = 0.3;
static CGFloat const lineWidth = 6;
static CGFloat const heightWithMsg = 100;

@implementation YSQCALayer

@dynamic lineWidth;
@dynamic color;
@dynamic frame;

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"color"]) {
        return YES;
    } else if ([key isEqualToString:@"lineWidth"]) {
        return YES;
    } else if ([key isEqualToString:@"frame"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat radius = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) /2 - self.lineWidth*2 ;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    //radius 半径 angle 角度 clockwise:顺时针
    [path addArcWithCenter:center radius:radius startAngle: 0 endAngle:M_PI*3/2.0  clockwise:YES];
    CGContextAddPath(ctx, path.CGPath);
    CGContextSetLineWidth(ctx, self.lineWidth);
    CGContextSetStrokeColorWithColor(ctx, self.color.CGColor);
    CGContextStrokePath(ctx);
}

@end


@interface SQProgressHUD ()

@property (nonatomic, strong) YSQCALayer *ysqLayer;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *textLable;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) SQProgressHUDType HUDType;

@end


@implementation SQProgressHUD

#pragma mark ---showHUD method
+ (instancetype)showHUDToView:(UIView *)view message:(NSString *)message animated:(BOOL)animated {
    SQProgressHUD *load = [[SQProgressHUD alloc]initWithView:view message:message];
    [view addSubview:load];
    [load startAnimation:animated];
    return load;
}

+ (instancetype)showHUDToView:(UIView *)view animated:(BOOL)animated {
    SQProgressHUD *load = [[SQProgressHUD alloc]initWithView:view message:nil];
    [view addSubview:load];
    [load startAnimation:animated];
    return load;
}

#pragma mark --init
- (instancetype)initWithView:(UIView *)view message:(NSString *)message{
    NSAssert(view, @"View must not be nil");
    self.title = message;
    return [self initWithFrame:view.bounds];
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.lineColor = [UIColor redColor];
        self.HUDType = self.title ? SQProgressHUDWithMessage : SQProgressHUDNormal;
        [self createBackView];
        [self createLayer];
        if (self.HUDType == SQProgressHUDWithMessage) {
            [self createTitleLable];
        }
    }
    return self;
}

#pragma mark ---UI
- (void)createTitleLable {
    CGFloat width = 0;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineSpacing = 4;
    NSDictionary *attr = @{NSFontAttributeName:TEXT_FONT, NSParagraphStyleAttributeName:paragraphStyle};
    CGSize size = [self.title boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    width = size.width  > backViewWidth ? size.width : backViewWidth;
    self.backView.frame = CGRectMake((self.frame.size.width - width) / 2, (self.frame.size.height - heightWithMsg) / 2, width + 20, heightWithMsg);
    self.ysqLayer.frame = CGRectMake(0, 0, self.backView.frame.size.width, self.backView.frame.size.height - size.height - 5);
        self.textLable = [[UILabel alloc]initWithFrame:CGRectMake(0, self.backView.frame.size.height - size.height - 5, self.backView.frame.size.width, size.height)];
    self.textLable.font =  TEXT_FONT;
    self.textLable.textColor = [UIColor whiteColor];
    self.textLable.textAlignment = NSTextAlignmentCenter;
    self.textLable.text = self.title;
    [self.backView addSubview:self.textLable];
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
    self.ysqLayer.color = self.lineColor;
    self.ysqLayer.lineWidth = lineWidth;
    self.ysqLayer.frame = self.backView.bounds;
    self.ysqLayer.position = CGPointMake(CGRectGetMidX(self.backView.bounds), CGRectGetMidY(self.backView.bounds));
    [self.backView.layer addSublayer:self.ysqLayer];
}


#pragma mark --- get self of view subviews
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


- (void)show:(BOOL)animated {
    NSAssert([NSThread isMainThread], @"SQProgressHUD needs to be accessed on the main thread.");
    self.backView.hidden = NO;
    self.backView.transform = CGAffineTransformScale(self.transform,0.1,0.1);
    if (animated) {
        // CGAffineTransform CGAffineTransformScale(CGAffineTransform t,CGFloat sx, CGFloat sy)
        //第一个参数transform类型,第二个x的比例,第三个参数y的比例
        [UIView animateWithDuration:duration animations:^{
            self.backView.transform = CGAffineTransformScale(self.transform,1.2,1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration animations:^{
                self.backView.transform = CGAffineTransformIdentity;
            }];
        }];
    } else {
        [UIView animateWithDuration:duration animations:^{
            self.backView.transform = CGAffineTransformIdentity;
        }];
    }
}

#pragma mark ---hide HUD

+ (BOOL)hideHUDToView:(UIView *)view animated:(BOOL)animated {
    SQProgressHUD *hud = [self HUDForView:view];
    if (hud != nil) {
        [hud hide:animated];
        return YES;
    }
    return NO;
}

+ (NSUInteger)hideAllHUDsToView:(UIView *)view animated:(BOOL)animated {
    NSArray *huds = [SQProgressHUD allHUDsForView:view];
    for (SQProgressHUD *hud in huds) {
        [hud hide:animated];
    }
    return [huds count];
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
        [UIView animateWithDuration:duration animations:^{
            self.backView.transform = CGAffineTransformScale(self.transform, 0.1, 0.1);
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

#pragma mark ---override setter method.
- (void)setLineColor:(UIColor *)lineColor {
    if (_lineColor != lineColor) {
        _lineColor = lineColor;
        self.ysqLayer.color = _lineColor;
    }
}

- (void)setLineWidth:(CGFloat)lineWidth {
    if (_lineWidth != lineWidth) {
        _lineWidth = lineWidth;
        self.ysqLayer.lineWidth = _lineWidth;
    }
}
@end

