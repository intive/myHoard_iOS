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
    UIImage *originalImage = [[UIImage alloc]init];
    originalImage = [self image];
    CGSize destinationSize;
    destinationSize.height = 150;
    destinationSize.width = 150;
    UIGraphicsBeginImageContext(destinationSize);
    [originalImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
