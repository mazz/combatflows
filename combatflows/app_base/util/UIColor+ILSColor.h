//
//  UIColor+ILSColor.h
//  scrappling
//
//  Created by Michael Hanna on 2014-08-31.
//  Copyright (c) 2014 ils. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ILSColor)

// scrappling
+ (UIColor*)scrapplingNavigationBarColor;
+ (UIColor*)scrapplingForegroundGreenColor;
+ (UIColor*)scrapplingForegroundOrangeColor;
+ (UIColor*)scrapplingSegmentedBlueColor;
+ (UIColor*)scrapplingForegroundBlueColor;
+ (UIColor*)scrapplingBackgroundBlueColor;
+ (UIColor*)scrapplingNavigationBlueColor;
+ (UIColor*)scrapplingSelectedBlueColor;
+ (UIColor*)scrapplingSeparatorColor;
+ (UIColor*)buyColor;
+ (UIColor*)purchasedColor;

+ (UIColor *)colorFromRGB:(int)rgbValue;
+ (UIColor *)colorFromRGBA:(int)rgbaValue;
@end
