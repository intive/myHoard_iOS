//
//  MHImageCache.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 06/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "TSFileCache.h"

@interface MHImageCache : TSFileCache

+ (instancetype)sharedInstance;

- (UIImage *)imageForKey:(NSString *)key;
- (UIImage *)thumbnailForKey:(NSString *)key;
- (void)cacheImage:(UIImage *)image forKey:(NSString *)key;
- (NSString *)cacheImage:(UIImage *)image;

- (void)clear;


#pragma mark - unavailable
+ (void)setSharedInstance:(TSFileCache *)instance __TSFileCacheUnavailable__;
+ (instancetype)cacheForURL:(NSURL *)directoryURL __TSFileCacheUnavailable__;
+ (instancetype)cacheInTemporaryDirectoryWithRelativeURL:(NSURL *)relativeURL __TSFileCacheUnavailable__;
- (void)storeData:(NSData *)data forKey:(NSString *)key __TSFileCacheUnavailable__;

@end

@interface MHImageCache (Subscript)

- (void)setObject:(UIImage *)image forKeyedSubscript:(NSString *)key;
- (UIImage *)objectForKeyedSubscript:(NSString *)key;

@end
