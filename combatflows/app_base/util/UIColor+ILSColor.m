//
//  UIColor+ILSColor.m
//  scrappling
//
//  Created by Michael Hanna on 2014-08-31.
//  Copyright (c) 2014 ils. All rights reserved.
//

#import "UIColor+ILSColor.h"

@implementation UIColor (ILSColor)

+ (UIColor*)scrapplingNavigationBarColor
{
    return [UIColor colorWithRed:229.0/255.0 green:230.0/255.0 blue:234.0/255.0 alpha:1.0];
}

+ (UIColor*)scrapplingForegroundGreenColor
{
    return [UIColor colorWithRed:0.0/255.0 green:239.0/255.0 blue:73.0/255.0 alpha:1.0];
}

+ (UIColor*)scrapplingForegroundOrangeColor
{
    return [UIColor colorWithRed:241.0/255.0 green:91.0/255.0 blue:44.0/255.0 alpha:1.0];
}

+ (UIColor*)scrapplingSegmentedBlueColor
{
    return [UIColor colorWithRed:12./255.0 green:94./255.0 blue:255./255.0 alpha:1.0];
}

+ (UIColor*)scrapplingForegroundBlueColor
{
    return [UIColor colorWithRed:0.0/255.0 green:174.0/255.0 blue:239./255.0 alpha:1.0];
}

+ (UIColor*)scrapplingBackgroundBlueColor
{
    return [UIColor colorWithRed:39./255. green:56./255. blue:67./255. alpha:1.];
}

+ (UIColor*)scrapplingNavigationBlueColor
{
    return [UIColor colorWithRed:69./255. green:97./255. blue:112./255. alpha:1.];
}

+ (UIColor*)scrapplingSelectedBlueColor
{
    return [UIColor colorWithRed:185./255. green:228./255. blue:255./255. alpha:1.];
}

+ (UIColor*)scrapplingSeparatorColor
{
    return [UIColor colorWithRed:31./255. green:47./255. blue:57./255. alpha:1.];
}

+ (UIColor*)buyColor
{
    return [UIColor colorWithRed:2.0/255.0 green:149.0/255.0 blue:40.0/255.0 alpha:1.0];
}

+ (UIColor*)purchasedColor
{
    return [UIColor colorWithRed:56.0/255.0 green:171.0/255.0 blue:251.0/255.0 alpha:1.0];
}

#pragma mark - Utils

+ (UIColor *)colorFromRGB:(int)rgbValue
{
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}

+ (UIColor *)colorFromRGBA:(int)rgbaValue
{
    return [UIColor colorWithRed:((float)((rgbaValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbaValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbaValue & 0xFF))/255.0 alpha:((float)((rgbaValue & 0xFF))/255.0)];
}

@end
