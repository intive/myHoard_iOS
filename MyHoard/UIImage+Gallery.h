//
//  UIImage+Gallery.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 06/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UIImageCompletionBlock)(UIImage *image);

@interface UIImage (Gallery)

+ (void)imageForAssetPath:(NSString *)path completion:(UIImageCompletionBlock)completion;
+ (void)thumbnailForAssetPath:(NSString *)path completion:(UIImageCompletionBlock)completion;

@end
