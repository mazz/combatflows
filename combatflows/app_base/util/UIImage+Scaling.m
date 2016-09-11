//
//  UIImage+Scaling.m
//  scrappling
//
//  Created by Michael Hanna on 2016-03-13.
//  Copyright © 2016 ils. All rights reserved.
//

#import "UIImage+Scaling.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (Scaling)

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToWidth:(float)i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;

    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;

    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (CGImageRef)scaledCGImageForImage:(UIImage*)image_ targetWidth:(CGFloat)targetWidth_
{
    CGImageRef imageRef = [image_ CGImage];

    CGRect imageRefRect = CGRectMake(0.0f, 0.0f, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));

    // we want to scale down the image while maintaining the aspect ratio, with emphasis on the width_

    CGFloat aspectRatio = targetWidth_ / imageRefRect.size.width;
    CGSize targetSize = CGSizeMake(targetWidth_, round(imageRefRect.size.height * aspectRatio));
    // make a new context and place a scaled-down image in there
    CGContextRef imageContextRef = CGBitmapContextCreateEmptyContext(targetSize);

    CGRect r;
    r.origin = CGPointZero;
    r.size = targetSize;

    CGContextSetInterpolationQuality(imageContextRef, kCGInterpolationHigh);
    CGContextDrawImage(imageContextRef, r, imageRef);
    CGContextFlush(imageContextRef);
    CGImageRef scaledImage = CGBitmapContextCreateImage(imageContextRef);
    CGContextRelease(imageContextRef);
    CGImageRelease(imageRef);

    CGContextRef containerContextRef = CGBitmapContextCreateEmptyContext(targetSize);
    CGContextSetInterpolationQuality(containerContextRef, kCGInterpolationHigh);
    CGContextDrawImage(containerContextRef, CGRectMake(0, 0, targetSize.width, targetSize.height), scaledImage);
    CGContextFlush(containerContextRef);
    CGImageRef renderedImage = CGBitmapContextCreateImage(containerContextRef);
    CGContextRelease(containerContextRef);
    CGImageRelease(scaledImage);

    return renderedImage;
}

+ (CGImageRef)scaledCGImageForImage:(UIImage*)image_ targetHeight:(CGFloat)targetHeight_
{
    //  *** create a temporary full-size image *** //
    CGImageRef imageRef = [image_ CGImage];

    CGRect imageRefRect = CGRectMake(0.0f, 0.0f, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));

    // we want to scale down the image while maintaining the aspect ratio, with emphasis on the height_

    CGFloat aspectRatio = targetHeight_ / imageRefRect.size.height;
    CGSize targetSize = CGSizeMake(round(imageRefRect.size.width * aspectRatio), targetHeight_);
    // make a new context and place a scaled-down image in there
    CGContextRef imageContextRef = CGBitmapContextCreateEmptyContext(targetSize);

    CGRect r;
    r.origin = CGPointZero;
    r.size = targetSize;

    CGContextSetInterpolationQuality(imageContextRef, kCGInterpolationHigh);
    CGContextDrawImage(imageContextRef, r, imageRef);
    CGContextFlush(imageContextRef);
    CGImageRef scaledImage = CGBitmapContextCreateImage(imageContextRef);
    CGContextRelease(imageContextRef);
    CGImageRelease(imageRef);

    CGContextRef containerContextRef = CGBitmapContextCreateEmptyContext(targetSize);
    CGContextSetInterpolationQuality(containerContextRef, kCGInterpolationHigh);
    CGContextDrawImage(containerContextRef, CGRectMake(0, 0, targetSize.width, targetSize.height), scaledImage);
    CGContextFlush(containerContextRef);
    CGImageRef renderedImage = CGBitmapContextCreateImage(containerContextRef);
    CGContextRelease(containerContextRef);
    CGImageRelease(scaledImage);

    return renderedImage;
}

- (NSString*)writeAsPNGToDocumentsDir
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* appName = [[NSProcessInfo processInfo] processName];

    //    NSString *defaultPath      = [NSString stringWithFormat:@"%@/%@%@.png", [dirUrl_ path], appName, dateString];

    NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%f.png", appName, [[NSDate date] timeIntervalSince1970]]];

    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)UIImagePNGRepresentation(self), NULL);
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);

    NSURL* fileUrl = [NSURL fileURLWithPath:filePath];

    // if the passed-in URL is a directory or is nil, write out to the Desktop
    CGImageDestinationRef ref = CGImageDestinationCreateWithURL((CFURLRef)fileUrl, (CFStringRef) @"public.png", 1, NULL);

    // add image to the ImageIO destination (specify the image we want to save)
    CGImageDestinationAddImage(ref, imageRef, NULL);

    if (!CGImageDestinationFinalize(ref)) {
        DDLogDebug(@"Error writing PNG file %@", [fileUrl path]);
    }
    else {
        DDLogDebug(@"wrote to: %@", fileUrl);
    }
    CFRelease(ref);
    CGImageRelease(imageRef);
    CFRelease(imageSource);

    return [fileUrl path];
}

CGContextRef CGBitmapContextCreateEmptyContext(CGSize size)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, (size.width * 4), colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    return context;
}

@end
