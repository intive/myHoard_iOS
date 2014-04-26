//
//  MHCollection+MHAPIUtilities.m
//  MyHoard
//
//  Created by user on 26/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHCollection+MHAPIUtilities.h"
#import "MHDatabaseManager.h"

@implementation MHCollection (MHAPIUtilities)

- (void)typeFromBoolValue:(NSNumber *)value {
    
    if ([value boolValue]) {
        self.objType = collectionTypePublic;
    }else {
        self.objType = collectionTypePrivate;
    }
}

@end
