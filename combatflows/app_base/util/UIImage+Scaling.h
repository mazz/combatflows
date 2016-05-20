//
//  UIImage+Scaling.h
//  scrappling
//
//  Created by Michael Hanna on 2016-03-13.
//  Copyright © 2016 ils. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Scaling)
+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width;
+ (CGImageRef)scaledCGImageForImage:(UIImage *)image_ targetWidth:(CGFloat)targetWidth_;
+ (CGImageRef)scaledCGImageForImage:(UIImage *)image_ targetHeight:(CGFloat)targetHeight_;
- (NSString *)writeAsPNGToDocumentsDir;
@end
