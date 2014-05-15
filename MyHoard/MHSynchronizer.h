//
//  MHSynchronizer.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 25/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHAPI.h"

typedef void(^MHSynchronizeCompletionBlock)(NSError* error);
typedef void(^MHCoreDataSyncCompletionBlock)(BOOL didFinishSync, NSError *error);
typedef void (^MHProgressBlock)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);

@interface MHSynchronizer : NSObject

- (id)initWithAPI:(MHAPI *)api;

- (void)synchronize:(MHSynchronizeCompletionBlock)completionBlock withProgress:(MHProgressBlock)progressBlock;

@end
