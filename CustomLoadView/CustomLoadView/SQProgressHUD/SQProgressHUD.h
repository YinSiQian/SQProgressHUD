//
//  SQProgressHUD.h
//
//  Created by ysq on 16/3/19.
//  Copyright © 2016年 ysq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum : NSUInteger {
    SQProgressHUDWithMessage,
    SQProgressHUDNormal,
    SQProgressHUDSuccess,
    SQProgressHUDFail,
} SQProgressHUDType;


@interface SQProgressHUD : UIView

/**
 *  if you reset the value of this property,the hud color will be changed. Default is red color.
 */
@property (nonatomic, strong) UIColor *lineColor;

/**
 *   if you reset the value of this property,the hud lineWidth will be changed.
 */
@property (nonatomic, assign) CGFloat lineWidth;

/**
 *  Creates a new HUD with message, adds it to provides view and show it. The counterpart to this method is hideHUDToView:animated:.
 *
 *  @param view     The view that the HUD  will be added to.
 *  @param messgae  You want to show message for user.
 *  @param animated  If the animated sets to YES , the HUD will perform an animation effects. Otherwise,the HUD will not use.
 *
 *  @return A reference to the created HUD.
 */
+ (instancetype)showHUDToView:(UIView *)view message:(NSString *)message animated:(BOOL)animated;

/**
 *   Creates a new HUD, adds it to provides view and show it.
 *
 *  @param view      The view that the HUD  will be added to.
 *  @param animated  If animated sets to YES, the SQProgressHUD will perform an animation effects.Otherwise,the HUD will not use.
 *
 *  @return A reference to the created HUD.
 */

+ (instancetype)showHUDToView:(UIView *)view animated:(BOOL)animated;

/**
 *  Creates a new successful status HUD, adds it to provides view and show it.And it will removed automatically after 2 seconds.
 *
 *  @param view  The view that the HUD  will be added to.
 *
 *  @return A reference to the created HUD.
 */
+ (instancetype)showSuccessToView:(UIView *)view;

/**
 *  Creates a new unsuccessful status HUD, adds it to provides view and show it.And it will removed automatically after 2 seconds
 *
 *  @param view The view that the HUD  will be added to.
 *
 *  @return A reference to the created HUD.
 */

+ (instancetype)showFailToView:(UIView *)view;


/**
 *  Finds the top-most  HUD subviews and hides it. The counterpart to this method is showHUDToView:animated:.
 *
 *  @param view     The view that is going to be searched for a HUD subview.
 *  @param animated If animated sets to YES, the SQProgressHUD will perform an animation effects.  Otherwise the HUD will not to use.
 *  @return YES if a HUD was found and removed,NO otherwise.
 */

+ (BOOL)hideHUDToView:(UIView *)view animated:(BOOL)animated;

/**
 *  Finds all the HUD subviews and hides them.
 *
 *  @param view  The view that is going to be searched for  HUD subviews.
 *  @param animated If animated sets to YES, the SQProgressHUD will perform an animation effects.  Otherwise the HUD will not to use.
 *
 *  @return the number of SQProgressHUDs found and removed.
 */
+ (NSUInteger)hideAllHUDsToView:(UIView *)view animated:(BOOL)animated;


@end


@interface YSQCALayer : CAShapeLayer
/**
 *   Sets the stroke color of layer.
 */
@property (nonatomic, strong) UIColor *color;


@end