//
//  MHSynchronizer.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 25/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHSynchronizer.h"
#import "MHDatabaseManager.h"

@interface MHSynchronizer()
{
    MHAPI* _api;
    NSInteger _oldMaxConcurrentOperationCount;
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

- (void)finish:(NSError *)error {
    if (_completionBlock) {
        _completionBlock(error);
    }
    self.completionBlock = nil;
    _api.operationQueue.maxConcurrentOperationCount = _oldMaxConcurrentOperationCount;
}

- (void)synchronize:(MHSynchronizeCompletionBlock)completionBlock {
    self.completionBlock = completionBlock;
    
    _oldMaxConcurrentOperationCount = _api.operationQueue.maxConcurrentOperationCount;
    _api.operationQueue.maxConcurrentOperationCount = 1;
    
    [_api readUserCollectionsWithCompletionBlock:^(id object, NSError *error) {
        if (error) {
            [self finish:error];
        }else {
            NSArray *coreDataCollections = [MHDatabaseManager allCollections];
            if (coreDataCollections.count) {
                for (NSInteger i = 0; i < coreDataCollections.count; i++) {
                    MHCollection* c = coreDataCollections[i];
                    [_api readAllItemsOfCollection:c completionBlock:^(id object, NSError *error) {
                        if (i == (coreDataCollections.count - 1)) {
                            [self finish:nil];
                        }
                    }];
                }
            } else {
                [self finish:nil];
            }
        }
    }];
}

@end
