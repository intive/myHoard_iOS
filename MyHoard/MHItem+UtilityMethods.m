//
//  MHItem+UtilityMethods.m
//  MyHoard
//
//  Created by user on 27/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//
#import <CoreLocation/CLLocation.h>

#import "MHItem+UtilityMethods.h"
#import "NSString+RFC3339.h"

@implementation MHItem (UtilityMethods)


- (void)locationParser:(NSDictionary *)locationValue {
    
    if (locationValue[@"location"] != nil) {
        self.objLocation = [[CLLocation alloc]initWithLatitude:[[locationValue objectForKey:@"location.lat"]doubleValue]longitude:[[locationValue objectForKey:@"location.lng"]doubleValue]];
    }else {
        self.objLocation = nil;
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
