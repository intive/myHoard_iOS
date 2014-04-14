//
//  MHAPI.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 27/02/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//
typedef enum  {
	MHThumbnailx160 = 1,
	MHThumbnailx300,
    MHThumbnailx340,
    MHThumbnailx500,
} MHThumbnailSize;

#import <Foundation/Foundation.h>

#import <AFNetworking.h>
#import "MHUserProfile.h"
#import "MHCollection.h"

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

- (AFHTTPRequestOperation *)refreshTokenForUser:(NSString *)email
                                   withPassword:(NSString *)password
                                completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)createCollection:(NSString *)name
                             withDescription:(NSString *)desc
                                    withTags:(NSArray *)tags
                             completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)readUserCollectionsWithCompletionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)updateCollectionWithId:(NSString *)collectionId
                                          withName:(NSString *)newName
                                   withDescription:(NSString *)newDescription
                                          withTags:(NSArray *)newTags
                                   completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)readUserCollectionWithId:(NSString *)collectionId
                                     completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)deleteCollectionWithId:(NSString *)collectionId
                                   completionBlock:(MHAPICompletionBlock)completionBlock;

@end
