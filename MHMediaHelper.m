//
//  MHMediaHelper.m
//  MyHoard
//
//  Created by Milena Gnoińska on 25.02.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHMediaHelper.h"

@implementation MHMediaHelper

-(UIImage*) thumbnail
{
    NSURL *url = [NSURL fileURLWithPath:self.objLocalPath];
    NSMutableArray *thumbnails = [[NSMutableArray alloc]init];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:url
             resultBlock:^(ALAsset *asset)
     {
         CGImageRef ref = [asset aspectRatioThumbnail];
         UIImage *thumbnail = [UIImage imageWithCGImage:ref];
         [thumbnails addObject:thumbnail];
     }
     
            failureBlock:^(NSError *error)
     {
         NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
     }
     ];
    return [thumbnails objectAtIndex:1];

}

-(UIImage*) image
{
    NSURL *url = [NSURL fileURLWithPath:self.objLocalPath];
    NSMutableArray *images = [[NSMutableArray alloc]init];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:url
             resultBlock:^(ALAsset *asset)
     {
         UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
         [images addObject:image];
     }
     
            failureBlock:^(NSError *error)
     {
         NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
     }
     ];
    
    return [images objectAtIndex:1];
}

@end
