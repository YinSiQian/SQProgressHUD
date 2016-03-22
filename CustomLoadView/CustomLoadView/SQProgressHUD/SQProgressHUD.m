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

@property (nonatomic, strong) YSQCALayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *resultLayer;
@property (nonatomic, strong) CAShapeLayer *FailTopLayer;
@property (nonatomic, strong) CAShapeLayer *FailBottomLayer;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *textLable;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) SQProgressHUDType HUDType;

@end


@implementation SQProgressHUD

#pragma mark ---class method
+ (instancetype)showHUDToView:(UIView *)view message:(NSString *)message animated:(BOOL)animated {
    SQProgressHUD *load = [[SQProgressHUD alloc]initWithView:view message:message];
    [load initType:SQProgressHUDWithMessage];
    [view addSubview:load];
    [load startAnimation:animated];
    return load;
}

+ (instancetype)showHUDToView:(UIView *)view animated:(BOOL)animated {
    SQProgressHUD *load = [[SQProgressHUD alloc]initWithView:view message:nil];
    [load initType:SQProgressHUDNormal];
    [view addSubview:load];
    [load startAnimation:animated];
    return load;
}

+ (instancetype)showSuccessToView:(UIView *)view  {
    SQProgressHUD *load = [[SQProgressHUD alloc]initWithView:view message:nil];
    [load initType:SQProgressHUDSuccess];
    [view addSubview:load];
    [load startSuccessAnimation:NO];
    return load;
}

+ (instancetype)showFailToView:(UIView *)view {
    SQProgressHUD *load = [[SQProgressHUD alloc]initWithView:view message:nil];
    [load initType:SQProgressHUDFail];
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

- (void)initType:(SQProgressHUDType)type {
    switch (type) {
        case SQProgressHUDSuccess: {
            [self createResultLayer];
            break;
        }
        case SQProgressHUDFail: {
            [self createFailLayer];
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
- (void)createTitleLable {
    CGFloat width = 0;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineSpacing = 4;
    NSDictionary *attr = @{NSFontAttributeName:TEXT_FONT, NSParagraphStyleAttributeName:paragraphStyle};
    CGSize size = [self.title boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    width = size.width  > backViewWidth ? size.width : backViewWidth;
    self.backView.frame = CGRectMake((self.frame.size.width - width) / 2, (self.frame.size.height - heightWithMsg) / 2, width + 20, heightWithMsg);
    self.circleLayer.frame = CGRectMake(0, 0, self.backView.frame.size.width, self.backView.frame.size.height - size.height - 5);
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

- (void)createResultLayer {
    self.resultLayer = [CAShapeLayer layer];
    self.resultLayer.strokeColor = [UIColor redColor].CGColor;
    self.resultLayer.lineWidth = lineWidth;
    self.resultLayer.frame = self.backView.bounds;
    self.resultLayer.position = CGPointMake(CGRectGetMidX(self.backView.bounds), CGRectGetMidY(self.backView.bounds));
    self.resultLayer.fillColor = [UIColor clearColor].CGColor;
    self.resultLayer.strokeEnd = 1;
    self.resultLayer.path = [self getBezierPthWithLayer:self.resultLayer].CGPath;
    [self.backView.layer addSublayer:self.resultLayer];
}

- (void)createLayer {
    self.circleLayer = [YSQCALayer layer];
    self.circleLayer.contentsScale = [UIScreen mainScreen].scale;
    self.circleLayer.color = self.lineColor;
    self.circleLayer.lineWidth = lineWidth;
    self.circleLayer.frame = self.backView.bounds;
    self.circleLayer.position = CGPointMake(CGRectGetMidX(self.backView.bounds), CGRectGetMidY(self.backView.bounds));
    [self.backView.layer addSublayer:self.circleLayer];
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

#pragma mark ---Animation
- (void)startSuccessAnimation:(BOOL)animated {
    CABasicAnimation *success = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    success.duration = 0.8;
    success.fromValue = @0;
    success.toValue = @1;
    success.delegate = self;
    [success setValue:@"success" forKey:key_animation];
    [self.resultLayer addAnimation:success forKey:nil];
    [self show:animated];
}

- (void)startAnimation:(BOOL)animated {
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

/*  失败动画参考:http://www.jianshu.com/p/56448d3d3596 */
- (void)showFailAnimationOne {
    
    CGFloat partLength = 40 * 2 / 8;
    CGFloat pathPartCount = 5;
    CGFloat visualPathPartCount = 4;
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat originY = CGRectGetMidY(self.backView.bounds) - 40;
    CGFloat destY = originY + partLength * pathPartCount;
    [path moveToPoint:CGPointMake(CGRectGetMidX(self.backView.bounds), originY)];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(self.backView.bounds), destY)];
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
    anima.duration = 0.5;
    [self.FailTopLayer addAnimation:anima forKey:nil];
 
}

- (void)showFailAnimationTwo {
    CGFloat partLength = 40 * 2 / 8;
    CGFloat pathPartCount = 2;
    CGFloat visualPathPartCount = 1;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat originY = CGRectGetMidY(self.backView.bounds) + 40;
    CGFloat destY = originY - partLength * pathPartCount;
    [path moveToPoint:CGPointMake(CGRectGetMidX(self.backView.bounds), originY)];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(self.backView.bounds), destY)];
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
    animationGroup.duration = 0.5;
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
        [self shakeFailAnimation];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hide:NO];
    });
}

#pragma mark ---override setter method.
- (void)setLineColor:(UIColor *)lineColor {
    if (_lineColor != lineColor) {
        _lineColor = lineColor;
        self.circleLayer.color = _lineColor;
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

