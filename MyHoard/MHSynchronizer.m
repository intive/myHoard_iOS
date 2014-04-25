//
//  MHSynchronizer.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 25/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHSynchronizer.h"

@interface MHSynchronizer()
{
    MHAPI* _api;
}

@property (nonatomic, copy) MHSynchronizeCompletionBlock completionBlock;

@end

@implementation MHSynchronizer

- (id)initWithAPI:(MHAPI *)api {
    self = [super init];
    if (self) {
        _api = api;
    }
    return self;
}

- (void)finish {
    if (_completionBlock) {
        _completionBlock();
    }
    self.completionBlock = nil;
}

- (void)synchronize:(MHSynchronizeCompletionBlock)completionBlock {
    self.completionBlock = completionBlock;
    
    [self finish];
}

@end
