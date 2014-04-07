//
//  MHAPI.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 27/02/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking.h>
#import "MHUserProfile.h"

typedef void (^MHAPICompletionBlock)(id object, NSError *error);

@interface MHAPI : AFHTTPRequestOperationManager

+ (instancetype)getInstance;

+ (void)setSharedAPIInstance:(MHAPI *)api;

- (NSString *)serverUrl;

- (AFHTTPRequestOperation *)createUser:(NSString *)email
                          withPassword:(NSString *)password
                       completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)readUserWithCompletionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)accessTokenForUser:(NSString *)email
                                  withPassword:(NSString *)password
                               completionBlock:(MHAPICompletionBlock)completionBlock;

- (void)logout:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)updateUser:(NSString *)username
                          withPassword:(NSString *)password
                              andEmail:(NSString *)email
                       completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)deleteUserWithCompletionBlock:(MHAPICompletionBlock)completionBlock;

@end
