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

@interface MHSynchronizer : NSObject

- (id)initWithAPI:(MHAPI *)api;

- (void)synchronize:(MHSynchronizeCompletionBlock)completionBlock;

@end
