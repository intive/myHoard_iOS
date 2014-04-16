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
    NSURL *url = [NSURL URLWithString:path];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:url
             resultBlock:^(ALAsset *asset) {
                 ALAssetRepresentation* r = [asset defaultRepresentation];
                 CGImageRef img = [r fullScreenImage];
                 UIImage* image = [UIImage imageWithCGImage:img];
                 
                 CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
                 completion(image, location.coordinate);
             }
     
            failureBlock:^(NSError *error)
     {
         completion(nil, kCLLocationCoordinate2DInvalid);
     }];
}

+ (void)thumbnailForAssetPath:(NSString *)path completion:(UIImageCompletionBlock)completion {
    NSURL *url = [NSURL URLWithString:path];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library assetForURL:url
             resultBlock:^(ALAsset *asset) {
                 CGImageRef ref = [asset aspectRatioThumbnail];
                 UIImage* thumbnail = [UIImage imageWithCGImage:ref];
                 
                 CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];

                 completion(thumbnail, location.coordinate);
             }
     
            failureBlock:^(NSError *error) {
                completion(nil, kCLLocationCoordinate2DInvalid);
            }];
}

@end
