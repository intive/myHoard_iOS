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
    
    [_api readUserCollectionsWithCompletionBlock:^(id object, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            
            [alert show];
            [self finish];
        }else {
            NSArray *coreDataCollections = [MHDatabaseManager allCollections];
            if (coreDataCollections.count) {
                for (MHCollection *eachCollection in coreDataCollections) {
                    [_api readAllItemsOfCollection:eachCollection completionBlock:^(id object, NSError *error) {
                        if (error) {
                            UIAlertView *alert = [[UIAlertView alloc]
                                                  initWithTitle:@"Error"
                                                  message:error.localizedDescription
                                                  delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
                            
                            [alert show];
                        }else {
                            [self finish];
                        }
                    }];
                }
            }else {
                [self finish];
            }
        }
    }];
}

@end
