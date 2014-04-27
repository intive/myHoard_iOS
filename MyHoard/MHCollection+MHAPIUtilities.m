//
//  MHCollection+MHAPIUtilities.m
//  MyHoard
//
//  Created by user on 26/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHCollection+MHAPIUtilities.h"
#import "MHDatabaseManager.h"
#import "NSString+RFC3339.h"

@implementation MHCollection (MHAPIUtilities)

- (void)typeFromBoolValue:(NSNumber *)value {
    
    if ([value boolValue]) {
        self.objType = collectionTypePublic;
    }else {
        self.objType = collectionTypePrivate;
    }
}

+ (NSDate *)createdDateFromString:(NSString *)dateString {
    NSDate *createdDate = [dateString dateFromRFC3339String];
    return createdDate;
}

- (void)modifiedDateFromString:(NSString *)dateString {
    self.objModifiedDate = [dateString dateFromRFC3339String];
}
@end
