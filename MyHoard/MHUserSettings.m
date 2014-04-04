//
//  MHUserSettings.m
//  MyHoard
//
//  Created by user on 13/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHUserSettings.h"

NSString *const stringTypeServerOne = @"Python";
NSString *const stringTypeServerTwo = @"Java_one";
NSString *const stringTypeServerThree = @"Java_two";

@implementation MHUserSettings
{
    NSUserDefaults *_userDefaults;
}


- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults {
    
    self = [super init];
    if (self) {
        _userDefaults = userDefaults;
    }
    
    return self;
}

+ (MHServerType)serverType {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultsResult = [NSString stringWithFormat:@"%@",[defaults objectForKey:@"server_preference"]];

    if (!defaultsResult.length)
        NSLog(@"No default server defined in user default settings");

    
    if ([defaultsResult isEqualToString:stringTypeServerOne]) {
        return MHServerTypePython;
    }else if ([defaultsResult isEqualToString:stringTypeServerTwo]) {
        return MHServerTypeJava1;
    }else {
        return MHServerTypeJava2;
    }
}

- (MHServerType)wrappigMethod {
    
    return [MHUserSettings serverType];
}

@end
