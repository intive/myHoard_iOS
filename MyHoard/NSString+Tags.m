//
//  NSString+Tags.m
//  MyHoard
//
//  Created by Karol Kogut on 08.04.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "NSString+Tags.h"

@implementation NSString (Tags)

- (NSArray*)tags
{
    NSArray *potentailTags = [[self componentsSeparatedByString:@" "] mutableCopy];
    NSMutableArray *tagsArray = [NSMutableArray arrayWithCapacity:potentailTags.count];

    NSString* tmpString = nil;
    for (NSString* s in potentailTags)
    {
        tmpString = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        tmpString = [tmpString stringByReplacingOccurrencesOfString:@"#" withString:@""];

        if (tmpString.length && ![tagsArray containsObject:tmpString])
            [tagsArray addObject:tmpString];
    }

    return tagsArray.count ? tagsArray : nil;
}

@end
