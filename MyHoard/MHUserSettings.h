//
//  MHUserSettings.h
//  MyHoard
//
//  Created by user on 13/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
	MHServerTypePython = 1,
	MHServerTypeJava1,
    MHServerTypeJava2,
} MHServerType;

@interface MHUserSettings : NSObject

+ (MHServerType)serverType;
- (id)initWithUserDefaults: (NSUserDefaults *)userDefaults;
- (MHServerType)wrappigMethod;

@end
