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
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    UIImage *thumbnail1 = [[UIImage alloc]init];
    [library assetForURL:url
             resultBlock:^(ALAsset *asset)
     {
         CGImageRef ref = [asset aspectRatioThumbnail];
         UIImage *thumbnail = [UIImage imageWithCGImage:ref];
         [thumbnail1 setValue:thumbnail forKey:@"thumbnail"];
     }
     
            failureBlock:^(NSError *error)
     {
         NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
     }
     ];
    return thumbnail1;

}

-(UIImage*) image
{
    NSURL *url = [NSURL fileURLWithPath:self.objLocalPath];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    UIImage *image1 = [[UIImage alloc]init];
    [library assetForURL:url
             resultBlock:^(ALAsset *asset)
     {
         UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
         [image1 setValue:image forKey:@"image"];
     }
     
            failureBlock:^(NSError *error)
     {
         NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
     }
     ];
    
    return image1;
}

@end
