//
//  NSObject+UIFont_SCRFont.m
//  scrappling
//
//  Created by Michael Hanna on 2014-10-13.
//  Copyright (c) 2014 ils. All rights reserved.
//

#import "UIFont+SCRFont.h"

@implementation UIFont (SCRFont)

+ (UIFont *)buttonTitleFont
{
    return [UIFont systemFontOfSize:14.0];
}

+ (UIFont *)productCellTitleFont
{
    return [UIFont boldSystemFontOfSize:12.];
}

+ (UIFont *)productCellSubtitleFont
{
    return [UIFont systemFontOfSize:9.];
}

+ (UIFont *)productCellBuyMeFont
{
    return [UIFont italicSystemFontOfSize:14.];
}

+ (UIFont *)productCellPurchasedFont
{
    return [UIFont systemFontOfSize:14.];
}

@end
