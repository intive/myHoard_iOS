//
//  UIImage+Gallery.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 06/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "UIImage+Gallery.h"

@implementation UIImage (Gallery)

+ (void)imageForAssetPath:(NSString *)path completion:(UIImageCompletionBlock)completion {
    NSURL *url = [NSURL fileURLWithPath:path];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:url
             resultBlock:^(ALAsset *asset) {
                 UIImage* image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                 completion(image);
             }
     
            failureBlock:^(NSError *error)
     {
         completion(nil);
     }];
}

+ (void)thumbnailForAssetPath:(NSString *)path completion:(UIImageCompletionBlock)completion {
    NSURL *url = [NSURL fileURLWithPath:path];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:url
             resultBlock:^(ALAsset *asset) {
                 CGImageRef ref = [asset aspectRatioThumbnail];
                 UIImage* thumbnail = [UIImage imageWithCGImage:ref];
                 completion(thumbnail);
             }
     
            failureBlock:^(NSError *error) {
                completion(nil);
            }];
}

@end
