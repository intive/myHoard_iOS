//
//  UIImage+customImage.m
//  MyHoard
//
//  Created by user on 09/05/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "UIImage+customImage.h"

@implementation UIImage (customImage)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    
    UIGraphicsBeginImageContext(size);
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:5];
    [color setFill];
    [path fill];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
