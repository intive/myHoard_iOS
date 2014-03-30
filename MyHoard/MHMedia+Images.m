//
//  MHMediaHelper.m
//  MyHoard
//
//  Created by Milena Gnoińska on 25.02.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHMedia+Images.h"

@implementation MHMedia (Images)

- (UIImage*) thumbnail {
    NSURL *url = [NSURL fileURLWithPath:self.objLocalPath];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    __block UIImage *thumbnail = nil;
    [library assetForURL:url
             resultBlock:^(ALAsset *asset) {
         CGImageRef ref = [asset aspectRatioThumbnail];
         thumbnail = [UIImage imageWithCGImage:ref];
    }
     
            failureBlock:^(NSError *error) {
         NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
    }];

    return thumbnail;
}

- (UIImage*) image {
    NSURL *url = [NSURL fileURLWithPath:self.objLocalPath];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    __block UIImage *image = nil;
    [library assetForURL:url
             resultBlock:^(ALAsset *asset) {
         image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
    }
     
            failureBlock:^(NSError *error)
    {
         NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
    }];
    
    return image;
}

@end
