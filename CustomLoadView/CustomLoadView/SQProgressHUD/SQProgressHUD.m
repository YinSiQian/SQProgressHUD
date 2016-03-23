//
//  SQProgressHUD.m
//
//  Created by ysq on 16/3/19.
//  Copyright © 2016年 ysq. All rights reserved.
//

#import "SQProgressHUD.h"

#define TEXT_FONT  [UIFont boldSystemFontOfSize:14]

static NSString *const key_animation = @"key_animation";
static CGFloat const cornerRadius = 6;
static CGFloat const backViewWidth = 80;
static CGFloat const backViewHeight = 80;
static CGFloat const duration = 0.3;
static CGFloat const failDuration = 0.5;
static CGFloat const lineWidth = 6;
static CGFloat const heightWithMsg = 100;
static CGFloat const MAX_WIDTH = 300;
static CGFloat const removeTime = 1.5f;

@interface SQProgressHUD ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *resultLayer;
@property (nonatomic, strong) CAShapeLayer *FailTopLayer;
@property (nonatomic, strong) CAShapeLayer *FailBottomLayer;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *text;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) SQProgressHUDType HUDType;
@property (nonatomic, assign) BOOL shake;

@end


@implementation SQProgressHUD

#pragma mark ---class method
+ (instancetype)showHUDToView:(UIView *)view message:(NSString *)message animated:(BOOL)animated {
    SQProgressHUD *load = [[SQProgressHUD alloc]initWithView:view message:message];
    [load initType:SQProgressHUDWithMessage shake:NO];
    [view addSubview:load];
    [load startAnimation:animated];
    return load;
}

+ (instancetype)showHUDToView:(UIView *)view animated:(BOOL)animated {
    SQProgressHUD *load = [[SQProgressHUD alloc]initWithView:view message:nil];
    [load initType:SQProgressHUDNormal shake:NO];
    [view addSubview:load];
    [load startAnimation:animated];
    return load;
}

+ (instancetype)showSuccessToView:(UIView *)view {
    SQProgressHUD *load = [[SQProgressHUD alloc]initWithView:view message:nil];
    [load initType:SQProgressHUDSuccess shake:NO];
    [view addSubview:load];
    [load startSuccessAnimation:NO];
    return load;
}

+ (instancetype)showFailToView:(UIView *)view message:(NSString *)message shake:(BOOL)shake{
    SQProgressHUD *load = [[SQProgressHUD alloc]initWithView:view message:message];
    [load initType:SQProgressHUDFail shake:shake];
    [view addSubview:load];
    [load show:NO];
    return load;
}

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


#pragma mark --init

- (void)initType:(SQProgressHUDType)type shake:(BOOL)shake{
    self.shake = shake;
    switch (type) {
        case SQProgressHUDSuccess: {
            [self createResultLayer];
            break;
        }
        case SQProgressHUDFail: {
            [self createFailLayer];
            if (self.title) {
                [self createTitleLable];
                [self showFailMessageAnimation];
            }
            [self showFailAnimationOne];
            [self showFailAnimationTwo];
            break;
        }
        case SQProgressHUDNormal: {
            [self createLayer];
            break;
        }
        case SQProgressHUDWithMessage: {
            [self createLayer];
            [self createTitleLable];
            break;
        }
        default:
            break;
    }
}

- (instancetype)initWithView:(UIView *)view message:(NSString *)message{
    NSAssert(view, @"View must not be nil");
    self.title = message;
    return [self initWithFrame:view.bounds];
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.lineColor = [UIColor redColor];
        [self createBackView];
    }
    return self;
}

#pragma mark ---UI

- (void)resetFrame {
    CGFloat width = 0;
    CGSize size = [self computeSizeWithString:self.title];
    width = size.width  > backViewWidth ? size.width : backViewWidth;
    self.backView.frame = CGRectMake((self.frame.size.width - width) / 2, (self.frame.size.height - heightWithMsg) / 2, width + 20, heightWithMsg);
    if (self.HUDType == SQProgressHUDWithMessage) {
        self.circleLayer.frame = CGRectMake(0, 0, self.backView.frame.size.width, self.backView.frame.size.height - size.height - 5);
    } else if (self.HUDType == SQProgressHUDFail) {
        self.FailTopLayer.frame = CGRectMake(0, 0, self.backView.frame.size.width, self.backView.frame.size.height - size.height - 5);
        self.FailBottomLayer.frame = CGRectMake(0, 0, self.backView.frame.size.width, self.backView.frame.size.height - size.height - 5);
    }

}

- (void)createTitleLable {
    [self resetFrame];
    CGSize size = [self computeSizeWithString:self.title];
    self.text = [[UILabel alloc]initWithFrame:CGRectMake(0, self.backView.frame.size.height - size.height - 5, self.backView.frame.size.width, size.height)];
    self.text.font =  TEXT_FONT;
    self.text.textColor = [UIColor whiteColor];
    self.text.textAlignment = NSTextAlignmentCenter;
    self.text.text = self.title;
    [self.backView addSubview:self.text];
}

- (void)createBackView {
    self.backView = [[UIView alloc]initWithFrame:CGRectMake(0,0, backViewWidth, backViewHeight)];
    self.backView.center = self.center;
    self.backView.layer.cornerRadius = cornerRadius;
    self.backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
    self.backView.hidden = YES;
    [self addSubview:self.backView];
}

- (void)createResultLayer {
    self.resultLayer = [CAShapeLayer layer];
    self.resultLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.resultLayer.lineWidth = lineWidth;
    self.resultLayer.frame = self.backView.bounds;
    self.resultLayer.position = CGPointMake(CGRectGetMidX(self.backView.bounds), CGRectGetMidY(self.backView.bounds));
    self.resultLayer.fillColor = [UIColor clearColor].CGColor;
    self.resultLayer.strokeEnd = 1;
    self.resultLayer.path = [self getBezierPthWithLayer:self.resultLayer].CGPath;
    [self.backView.layer addSublayer:self.resultLayer];
}

- (void)createLayer {
    self.circleLayer = [CAShapeLayer layer];
    self.circleLayer.contentsScale = [UIScreen mainScreen].scale;
    self.circleLayer.strokeColor = self.lineColor.CGColor;
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleLayer.lineWidth = lineWidth;
    self.circleLayer.frame = self.backView.bounds;
    self.circleLayer.position = CGPointMake(CGRectGetMidX(self.backView.bounds), CGRectGetMidY(self.backView.bounds));
    [self.backView.layer addSublayer:self.circleLayer];
    
    //画圈圈
    CABasicAnimation *circle = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    circle.duration = duration;
    circle.fromValue = @0;
    circle.toValue = @1;
    [self.circleLayer addAnimation:circle forKey:nil];
}

- (void)createFailLayer {
    self.FailBottomLayer = [CAShapeLayer layer];
    self.FailBottomLayer.frame = self.backView.bounds;
    self.FailBottomLayer.lineWidth = lineWidth;
    self.FailBottomLayer.strokeColor = [UIColor orangeColor].CGColor;
    [self.backView.layer addSublayer: self.FailBottomLayer];
    
    self.FailTopLayer = [CAShapeLayer layer];
    self.FailTopLayer.frame = self.backView.bounds;
    self.FailTopLayer.lineWidth = lineWidth;
    self.FailTopLayer.strokeColor = [UIColor orangeColor].CGColor;
    [self.backView.layer addSublayer:self.FailTopLayer];
}

#pragma mark ---Computing size

- (CGSize)computeSizeWithString:(NSString *)string {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineSpacing = 4;
    NSDictionary *attr = @{NSFontAttributeName:TEXT_FONT, NSParagraphStyleAttributeName:paragraphStyle};
    CGSize size = [string boundingRectWithSize:CGSizeMake(MAX_WIDTH, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    return size;
}

#pragma mark ---Animation
- (void)startSuccessAnimation:(BOOL)animated {
    CABasicAnimation *success = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    success.duration = failDuration;
    success.fromValue = @0;
    success.toValue = @1;
    success.delegate = self;
    [success setValue:@"success" forKey:key_animation];
    [self.resultLayer addAnimation:success forKey:nil];
    [self show:animated];
}

- (void)startAnimation:(BOOL)animated {
    self.circleLayer.path = [self getCirclePathWithLayer:self.circleLayer].CGPath;
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotateAnimation.fromValue = @(2*M_PI);
    rotateAnimation.toValue = @0;
    rotateAnimation.duration = duration;
    rotateAnimation.repeatCount = HUGE;
    rotateAnimation.removedOnCompletion = NO;
    [self.circleLayer addAnimation:rotateAnimation forKey:key_animation];
    [self show:animated];
}

- (void)showFailMessageAnimation {
    CATransition *transition = [CATransition animation];
    transition.type = @"push";
    transition.subtype = kCATransitionFromLeft;
    transition.startProgress = 0.3;
    transition.endProgress = 1;
    transition.duration = failDuration;
    [self.text.layer addAnimation:transition forKey:nil];
}

/*  失败动画参考:http://www.jianshu.com/p/56448d3d3596 */
- (void)showFailAnimationOne {
    
    CGFloat partLength = 40 * 2 / 8;
    CGFloat pathPartCount = 5;
    CGFloat visualPathPartCount = 4;
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat startDes = CGRectGetMidY(self.backView.bounds) - 40;
    CGFloat endDes = startDes + partLength * pathPartCount;
    if (self.title) {
        startDes -= 10;
        endDes -=10;
    }
    [path moveToPoint:CGPointMake(CGRectGetMidX(self.backView.bounds), startDes)];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(self.backView.bounds), endDes)];
    self.FailTopLayer.path = path.CGPath;
    
    // end status
    CGFloat strokeStart = (pathPartCount - visualPathPartCount ) / pathPartCount;
    CGFloat strokeEnd = 1.0;
    self.FailTopLayer.strokeStart = strokeStart;
    self.FailTopLayer.strokeEnd = strokeEnd;
    
    // animation
    CABasicAnimation *startAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    startAnimation.fromValue = @0;
    startAnimation.toValue = @(strokeStart);
    
    CABasicAnimation *endAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    endAnimation.fromValue = @0;
    endAnimation.toValue = @(strokeEnd);
    
    CAAnimationGroup *anima = [CAAnimationGroup animation];
    anima.animations = @[startAnimation, endAnimation];
    anima.duration = failDuration;
    [self.FailTopLayer addAnimation:anima forKey:nil];
 
}

- (void)showFailAnimationTwo {
    CGFloat partLength = 40 * 2 / 8;
    CGFloat pathPartCount = 2;
    CGFloat visualPathPartCount = 1;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat startDes = CGRectGetMidY(self.backView.bounds) + 40;
    CGFloat endDes = startDes - partLength * pathPartCount;
    if (self.title) {
        endDes -= 10;
        startDes -=10;
    }
    [path moveToPoint:CGPointMake(CGRectGetMidX(self.backView.bounds), startDes)];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(self.backView.bounds), endDes)];
    self.FailBottomLayer.path = path.CGPath;
    
    CGFloat strokeStart = (pathPartCount - visualPathPartCount ) / pathPartCount;
    CGFloat strokeEnd = 1.0;
    self.FailBottomLayer.strokeStart = strokeStart;
    self.FailBottomLayer.strokeEnd = strokeEnd;
    
    // animation
    CABasicAnimation *startAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    startAnimation.fromValue = @0;
    startAnimation.toValue = @(strokeStart);
    
    CABasicAnimation *endAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    endAnimation.fromValue = @0;
    endAnimation.toValue = @(strokeEnd);
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[startAnimation, endAnimation];
    animationGroup.duration = failDuration;
    animationGroup.delegate = self;
    [animationGroup setValue:@"Fail" forKey:key_animation];
    [self.FailBottomLayer addAnimation:animationGroup forKey:nil];
}

- (void)shakeFailAnimation {
    CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    shakeAnimation.fromValue = @(-M_PI / 10);
    shakeAnimation.toValue = @(M_PI / 10);
    shakeAnimation.duration = 0.1;
    shakeAnimation.autoreverses = YES;
    shakeAnimation.repeatCount = 4;
    [self.backView.layer addAnimation:shakeAnimation forKey:nil];
}

#pragma mark --- get Animation path
- (UIBezierPath *)getCirclePathWithLayer:(CAShapeLayer *)layer {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat radius = MIN(CGRectGetWidth(layer.bounds), CGRectGetHeight(layer.bounds)) /2 - lineWidth*2 ;
    NSLog(@"%f",radius);
    CGPoint center = CGPointMake(CGRectGetMidX(layer.bounds), CGRectGetMidY(layer.bounds));
    [path addArcWithCenter:center radius:radius startAngle:0 endAngle:M_PI*3/2.0 clockwise:YES];
    return path;
}

- (UIBezierPath *)getBezierPthWithLayer:(CAShapeLayer *)layer {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(layer.bounds), CGRectGetMidY(layer.bounds));
    CGPoint firstPoint = centerPoint;
    firstPoint.x -= 60 / 2;
    firstPoint.y -= 30 / 6;
    [path moveToPoint:firstPoint];
    
    CGPoint secondPoint = centerPoint;
    secondPoint.x -= 40 / 8;
    secondPoint.y += 40 / 2;
    [path addLineToPoint:secondPoint];
    
    CGPoint thirdPoint = centerPoint;
    thirdPoint.x += 60 / 2;
    thirdPoint.y -= 40 / 2;
    [path addLineToPoint:thirdPoint];
    return path;
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

#pragma mark ---show HUD
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

#pragma mark --AnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    if ([[anim valueForKey:key_animation] isEqualToString:@"Fail"]) {
        if (self.shake) {
            [self shakeFailAnimation];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(removeTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hide:NO];
    });
}

#pragma mark ---override setter method.
- (void)setLineColor:(UIColor *)lineColor {
    if (_lineColor != lineColor) {
        _lineColor = lineColor;
        self.circleLayer.strokeColor = _lineColor.CGColor;
        self.resultLayer.strokeColor = _lineColor.CGColor;
        self.FailBottomLayer.strokeColor = _lineColor.CGColor;
        self.FailTopLayer.strokeColor = _lineColor.CGColor;
    }
}

- (void)setLineWidth:(CGFloat)lineWidth {
    if (_lineWidth != lineWidth) {
        _lineWidth = lineWidth;
        self.circleLayer.lineWidth = _lineWidth;
        self.resultLayer.lineWidth = _lineWidth;
        self.FailBottomLayer.lineWidth = _lineWidth;
        self.FailTopLayer.lineWidth = _lineWidth;
    }
}


@end

