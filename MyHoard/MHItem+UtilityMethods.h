//
//  MHItem+UtilityMethods.h
//  MyHoard
//
//  Created by user on 27/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHItem.h"

@interface MHItem (UtilityMethods)

- (void)locationParser:(NSDictionary *)locationValue;
+ (NSDate *)createdDateFromString:(NSString *)dateString;
- (void)modifiedDateFromString:(NSString *)dateString;

@end
