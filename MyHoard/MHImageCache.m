//
//  MHImageCache.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 06/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <CoreGraphics/CoreGraphics.h>

#import "MHImageCache.h"

@implementation MHImageCache

static MHImageCache *_sharedInstance = nil;
+ (instancetype)sharedInstance {
    if (!_sharedInstance) {
        NSString* path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];

        _sharedInstance = [super cacheInTemporaryDirectoryWithRelativeURL:[NSURL fileURLWithPath:path]];
        /// Prepare directory
        [_sharedInstance prepare:nil];
    }
    return _sharedInstance;
}

- (NSString*)hashForData:(NSData *)data
{
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, data.length, md5Buffer);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

- (UIImage *)thumbnailForKey:(NSString *)key {
    return [self imageForKey:[self keyForThumbnailWithBaseKey:key]];
}

- (UIImage *)imageForKey:(NSString *)key {
    NSData *data = [super dataForKey:key];
    return [UIImage imageWithData:data];
}

- (void)cacheImage:(UIImage *)image forKey:(NSString *)key {
    NSData *data = UIImagePNGRepresentation(image);
    [super storeData:data forKey:key];
}

- (NSString *)keyForThumbnailWithBaseKey:(NSString *)key {
    return [NSString stringWithFormat:@"%@_thumbnail", key];
}

- (UIImage*)thumbnailFromImage:(UIImage *)image {

    CGSize thumbSize = CGSizeMake(150, 150);
    
    if ( image.size.height > image.size.width ){
        
        CGFloat finalHeight = image.size.height * thumbSize.width / image.size.width;
        
        UIGraphicsBeginImageContextWithOptions( CGSizeMake(thumbSize.width, finalHeight), NO, 0.0);
        
        [image drawInRect:CGRectMake(0, 0, thumbSize.width, finalHeight)];
        
    } else {
        
        CGFloat finalWidth =  image.size.width * thumbSize.height / image.size.height;
        
        UIGraphicsBeginImageContextWithOptions( CGSizeMake(finalWidth, thumbSize.height), NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, finalWidth, thumbSize.height)];
        
    }
    
    UIImage *thumb = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return thumb;
}

- (NSString *)cacheImage:(UIImage *)image {
    NSData *data = UIImageJPEGRepresentation(image, 90);
    NSString *key = [self hashForData:data];
    [super storeData:data forKey:key];
    
    [self cacheImage:[self thumbnailFromImage:image] forKey:[self keyForThumbnailWithBaseKey:key]];
    return key;
}

- (void)clear {
    [super clear];
}

@end

@implementation MHImageCache (Subscript)

- (void)setObject:(UIImage *)image forKeyedSubscript:(NSString *)key {
    [self cacheImage:image forKey:key];
}

- (UIImage *)objectForKeyedSubscript:(NSString *)key {
    return [self imageForKey:key];
}

@end