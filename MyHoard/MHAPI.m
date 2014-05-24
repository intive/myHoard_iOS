//
//  MHAPI.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 27/02/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <CoreLocation/CLLocation.h>

#import "MHAPI.h"
#import "MHUserSettings.h"
#import "MHItem+UtilityMethods.h"
#import "MHDatabaseManager.h"
#import "MHCoreDataContext.h"
#import "NSString+RFC3339.h"
#import "MHImageCache.h"

static MHAPI *_sharedAPI = nil;

@interface MHAPI() {
    
    NSString* _accessToken;
    NSString* _refreshToken;
}

@end

@implementation MHAPI

+ (instancetype)getInstance
{
    return _sharedAPI;
}

+ (void)setSharedAPIInstance:(MHAPI *)api
{
    @synchronized (self) {
        _sharedAPI = api;
    }
}

- (NSString *)serverUrl {
    NSString *ret = @"";
    switch([MHUserSettings serverType]) {
        case MHServerTypePython:
            ret = @"http://78.133.154.18:8081";
            break;
        case MHServerTypeJava1:
            ret = @"http://78.133.154.39:1080";
            break;
        case MHServerTypeJava2:
            ret = @"http://78.133.154.39:2080";
            break;
    }
    return ret;
}

- (NSString *)urlWithPath:(NSString *)path {
    return [NSString stringWithFormat:@"%@/%@/", [self serverUrl], path];
}

#pragma User + Authorization & Authentication

- (void)logout:(MHAPICompletionBlock)completionBlock {
    _accessToken = nil;
    _refreshToken = nil;
    _userId = nil;
    _userPassword = nil;
    completionBlock(nil, nil);
}

- (BOOL)activeSession {
    
    if (_accessToken && _refreshToken) {
        return YES;
    }else {
        return NO;
    }
}

- (AFHTTPRequestOperation *)createUser:(NSString *)email
                          withPassword:(NSString *)password
                       completionBlock:(MHAPICompletionBlock)completionBlock
{
    NSError *error;
    
    AFJSONRequestSerializer* s = [AFJSONRequestSerializer serializer];
    NSMutableURLRequest *request = [s requestWithMethod:@"POST"
                                              URLString:[self urlWithPath:@"users"]
                                             parameters:@{@"email": email,
                                                          @"password": password}
                                                  error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          completionBlock(nil, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          [self localizedDescriptionForErrorCode:error];
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma read existing user

- (AFHTTPRequestOperation *)readUserWithCompletionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer *jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"GET" URLString:[NSString stringWithFormat:@"%@%@/", [self urlWithPath:@"users"],_userId] parameters:nil error:&error];
    
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          MHUserProfile *userProfile = [[MHUserProfile alloc]init];
                                                                          
                                                                          userProfile.username = [responseObject valueForKeyPath:@"username"];
                                                                          userProfile.email = [responseObject valueForKeyPath:@"email"];
                                                                          
                                                                          completionBlock(userProfile, nil);                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                              completionBlock(nil, error);
                                                                          }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark - update user

- (AFHTTPRequestOperation *)updateUser:(NSString *)username
                          withPassword:(NSString *)password
                              andEmail:(NSString *)email
                       completionBlock:(MHAPICompletionBlock)completionBlock {
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"PUT"
                                                        URLString:[NSString stringWithFormat:@"%@%@/", [self urlWithPath:@"users"],_userId]
                                                       parameters:@{@"username": username,
                                                                    @"password": password,
                                                                    @"email": email}
                                                            error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          MHUserProfile *userProfile = [[MHUserProfile alloc]init];
                                                                          
                                                                          userProfile.username = [responseObject valueForKeyPath:@"username"];
                                                                          userProfile.email = [responseObject valueForKeyPath:@"email"];
                                                                          
                                                                          completionBlock(userProfile, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          [self localizedDescriptionForErrorCode:error];
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark - delete user

- (AFHTTPRequestOperation *)deleteUserWithCompletionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"DELETE"
                                                        URLString:[NSString stringWithFormat:@"%@%@/", [self urlWithPath:@"users"],_userId]
                                                       parameters:nil
                                                            error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          completionBlock(nil, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          [self localizedDescriptionForErrorCode:error];
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark - refresh token

- (AFHTTPRequestOperation *)refreshTokenForUser:(NSString *)email
                                   withPassword:(NSString *)password
                                completionBlock:(MHAPICompletionBlock)completionBlock {
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"POST"
                                                        URLString:[self urlWithPath:@"oauth/token"]
                                                       parameters:@{@"email": email,
                                                                    @"password": password,
                                                                    @"grant_type": @"refresh_token",
                                                                    @"refresh_token": _refreshToken}
                                                            error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          _accessToken = responseObject[@"access_token"];
                                                                          _refreshToken = responseObject[@"refresh_token"];
                                                                          _userId = responseObject[@"user_id"];
                                                                          completionBlock(nil, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          [self localizedDescriptionForErrorCode:error];
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark get token/login

- (AFHTTPRequestOperation *)accessTokenForUser:(NSString *)email
                                  withPassword:(NSString *)password
                               completionBlock:(MHAPICompletionBlock)completionBlock {
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"POST"
                                                        URLString:[self urlWithPath:@"oauth/token"]
                                                       parameters:@{@"email": email,
                                                                    @"password": password,
                                                                    @"grant_type": @"password"}
                                                            error:&error];

    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          _accessToken = [responseObject valueForKeyPath:@"access_token"];
                                                                          _refreshToken = [responseObject valueForKeyPath:@"refresh_token"];
                                                                          _userId = [responseObject valueForKeyPath:@"user_id"];
                                                                          _userPassword = password;
                                                                          completionBlock(nil, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          [self localizedDescriptionForErrorCode:error];
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark Collections/create collection

- (AFHTTPRequestOperation *)createCollection:(MHCollection *)collection
                             completionBlock:(MHAPICompletionBlock)completionBlock
{
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSNumber *objType;
    
    if ([collection.objType isEqualToString:@"public"]) {
        objType = @YES;
    }else {
        objType = @NO;
    }
    
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:@{@"name": collection.objName,
                                                                                  @"public":objType}];
    
    if ([collection.tags count]) {
        NSMutableArray* tags = [NSMutableArray new];
        for (MHTag* tag in collection.tags) {
            [tags addObject:tag.tag];
        }
        params[@"tags"] = tags;
    }
    
    if (collection.objDescription) {
        params[@"description"] = collection.objDescription;
    }
    
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"POST"
                                                           URLString:[self urlWithPath:@"collections"]
                                                          parameters:params
                                                               error:&error];
    
    __block MHCollection* c = collection;
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          
                                                                          c.objCreatedDate = [MHCollection createdDateFromString:responseObject[@"created_date"]];
                                                                          [c modifiedDateFromString:responseObject[@"modified_date"]];
                                                                          c.objOwner = responseObject[@"owner"];
                                                                          c.objId = responseObject[@"id"];
                                                                          [c typeFromBoolValue:responseObject[@"public"]];
                                                                          c.objStatus = objectStatusOk;
                                                                          [[MHCoreDataContext getInstance] saveContext];
                                                                          
                                                                          completionBlock(c, error);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark read all of user collections

- (AFHTTPRequestOperation *)readUserCollectionsWithCompletionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"GET"
                                                           URLString:[self urlWithPath:[NSString stringWithFormat:@"users/%@/collections", _userId]]
                                                          parameters:nil
                                                               error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          NSArray *responseArray = responseObject;
                                                                          completionBlock(responseArray, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark read specified user collection

- (AFHTTPRequestOperation *)readUserCollection:(MHCollection *)collection
                               completionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"GET"
                                                           URLString:[NSString stringWithFormat:@"%@%@",[self urlWithPath:@"collections"],collection.objId]
                                                          parameters:nil
                                                               error:&error];
    
    __block MHCollection* c = collection;
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          
                                                                          c = [MHDatabaseManager insertCollectionWithObjName:responseObject[@"name"] objDescription:responseObject[@"description"] objTags:responseObject[@"tags"] objCreatedDate:[MHCollection createdDateFromString:responseObject[@"created_date"]] objModifiedDate:nil objOwnerNilAddLogedUserCode:responseObject[@"owner"] objStatus:objectStatusOk objType:nil];
                                                                          c.objId = responseObject[@"id"];
                                                                          [c typeFromBoolValue:responseObject[@"public"]];
                                                                          [c modifiedDateFromString:responseObject[@"modified_date"]];
                                                                          [[MHCoreDataContext getInstance]saveContext];
                                                                          
                                                                          completionBlock(c, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark update collection

- (AFHTTPRequestOperation *)updateCollection:(MHCollection *)collection
                             completionBlock:(MHAPICompletionBlock)completionBlock {
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSNumber *objType;
    
    if ([collection.objType isEqualToString:@"public"]) {
        objType = @YES;
    }else {
        objType = @NO;
    }
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:@{@"name": collection.objName,
                                                                                  @"public":objType}];
    
    if ([collection.tags count]) {
        NSMutableArray* tags = [NSMutableArray new];
        for (MHTag* tag in collection.tags) {
            [tags addObject:tag.tag];
        }
        params[@"tags"] = tags;
    }
    
    if (collection.objDescription) {
        params[@"description"] = collection.objDescription;
    }

    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"PUT"
                                                        URLString:[NSString stringWithFormat:@"%@%@/",[self urlWithPath:@"collections"],collection.objId]
                                                       parameters:params
                                                            error:&error];
    __block MHCollection *c = collection;
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          c.objCreatedDate = [MHCollection createdDateFromString:responseObject[@"created_date"]];
                                                                          [c modifiedDateFromString:responseObject[@"modified_date"]];
                                                                          c.objOwner = responseObject[@"owner"];
                                                                          c.objId = responseObject[@"id"];
                                                                          [c typeFromBoolValue:responseObject[@"public"]];
                                                                          c.objStatus = objectStatusOk;

                                                                          [[MHCoreDataContext getInstance] saveContext];
                                                                          
                                                                          completionBlock(c, error);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          [self localizedDescriptionForErrorCode:error];
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark delete collection

- (AFHTTPRequestOperation *)deleteCollection:(MHCollection *)collection
                             completionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"DELETE"
                                                        URLString:[NSString stringWithFormat:@"%@%@/",[self urlWithPath:@"collections"],collection.objId]
                                                       parameters:nil
                                                            error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          completionBlock(collection, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          [self localizedDescriptionForErrorCode:error];
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark Media/create media

- (AFHTTPRequestOperation *)createMedia:(MHMedia *)media
                        completionBlock:(MHAPICompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    __block MHMedia* m = media;
    
    NSData* assetData = [[MHImageCache sharedInstance]dataForKey:media.objKey];
    
    [manager POST:[self urlWithPath:@"media"] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:assetData name:@"image" fileName:[NSString stringWithFormat:@"%@.jpg", m.objKey] mimeType:@"image/*"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        m.objId = responseObject[@"id"];
        m.objStatus = objectStatusOk;
        completionBlock(m, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
    
    
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    
    return nil;
}

#pragma mark read media

- (AFHTTPRequestOperation *)readMedia:(MHMedia *)media
                      completionBlock:(MHAPICompletionBlock)completionBlock
                        progressBlock:(MHProgressBlock)progressBlock{
    
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"GET"
                                                           URLString:[NSString stringWithFormat:@"%@%@/",[self urlWithPath:@"media"],media.objId]
                                                          parameters:nil
                                                               error:&error];
    
    __block MHMedia *tmpMedia = media;
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          [[MHImageCache sharedInstance] cacheImage:responseObject forKey:media.objId];
                                                                          tmpMedia.objKey = media.objId;
                                                                          completionBlock(tmpMedia, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    
    [operation setDownloadProgressBlock:progressBlock];
    
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark update media

- (AFHTTPRequestOperation *)updateMedia:(MHMedia *)media
                        completionBlock:(MHAPICompletionBlock)completionBlock {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    __block MHMedia *tmpMedia = media;
    
    NSData* assetData = [[MHImageCache sharedInstance] dataForKey:media.objKey];
    [manager POST:[NSString stringWithFormat:@"%@%@/",[self urlWithPath:@"media"],media.objId] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:assetData name:@"image" fileName:media.objKey mimeType:@"image/*"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        tmpMedia.objId = responseObject[@"id"];
        tmpMedia.objStatus = objectStatusOk;
        completionBlock(tmpMedia, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
    
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    
    return nil;
}

#pragma mark delete media

- (AFHTTPRequestOperation *)deleteMedia:(MHMedia *)media
                        completionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"DELETE"
                                                           URLString:[NSString stringWithFormat:@"%@%@/",[self urlWithPath:@"media"],media.objId]
                                                          parameters:nil
                                                               error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          completionBlock(media, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark read thumbnail

- (AFHTTPRequestOperation *)readThumbnail:(MHThumbnailSize)size
                                 forMedia:(MHMedia *)media
                          completionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSString *thumbnailSize = @"";
    
    switch (size) {
        case MHThumbnailx160:
            thumbnailSize = @"160";
            break;
        case MHThumbnailx300:
            thumbnailSize = @"300";
            break;
        case MHThumbnailx340:
            thumbnailSize = @"340";
            break;
        case MHThumbnailx500:
            thumbnailSize = @"500";
            break;
    }
    
    
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"GET"
                                                           URLString:[NSString stringWithFormat:@"%@%@/?size=%@",[self urlWithPath:@"media"],media.objId,thumbnailSize]
                                                          parameters:nil
                                                               error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          completionBlock(responseObject, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark Item/create item

- (AFHTTPRequestOperation *)createItem:(MHItem *)item
                       completionBlock:(MHAPICompletionBlock)completionBlock
{
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableArray* mediaIds = [[NSMutableArray alloc] init];
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:@{@"name": item.objName,
                                                                                  @"collection": item.collection.objId}];
    if ([item.media count] > 0) {
        for (MHMedia* media in item.media) {
            if (media.objId) {
                [mediaIds addObject:media.objId];
            }
        }
        params[@"media"] = mediaIds;
    }
    
    if ([item.tags count]) {
        NSMutableArray* tags = [NSMutableArray new];
        for (MHTag* tag in item.tags) {
            [tags addObject:tag.tag];
        }
        params[@"tags"] = tags;
    }

    if (item.objDescription) {
        params[@"description"] = item.objDescription;
    }
    
    CLLocation *l = item.objLocation;
    if (l) {
        params[@"location"] = @{@"lat": @(l.coordinate.latitude),
                                @"lng": @(l.coordinate.longitude)};
    }
    
    
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"POST"
                                                           URLString:[self urlWithPath:@"items"]
                                                          parameters:params
                                                               error:&error];
    
    __block MHItem* i = item;
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          i.objId = responseObject[@"id"];
                                                                          i.objName = responseObject[@"name"];
                                                                          i.objDescription = responseObject[@"description"];
                                                                          [i locationParser:responseObject[@"location"]];
                                                                          i.objCreatedDate = [MHItem createdDateFromString:responseObject[@"created_date"]];
                                                                          i.objOwner = responseObject[@"owner"];
                                                                          [i modifiedDateFromString:responseObject[@"modified_date"]];
                                                                          i.objStatus = objectStatusOk;
                                                                          
                                                                          [[MHCoreDataContext getInstance] saveContext];
                                                                          completionBlock(i, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark read single item

- (AFHTTPRequestOperation *)readItem:(MHItem *)item
                     completionBlock:(MHAPICompletionBlock)completionBlock
{
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"GET"
                                                           URLString:[NSString stringWithFormat:@"%@%@/",[self urlWithPath:@"items"],item.objId]
                                                          parameters:nil
                                                               error:&error];
    
    __block MHItem* i = item;
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          i.objId = responseObject[@"id"];
                                                                          i.objName = responseObject[@"name"];
                                                                          i.objDescription = responseObject[@"description"];
                                                                          i.objCreatedDate = [MHItem createdDateFromString:responseObject[@"created_date"]];
                                                                          i.objOwner = responseObject[@"owner"];
                                                                          [i locationParser:responseObject[@"location"]];
                                                                          [i modifiedDateFromString:responseObject[@"modified_date"]];
                                                                          [[MHCoreDataContext getInstance] saveContext];
                                                                          completionBlock(i, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark read items of a collection

- (AFHTTPRequestOperation *)readAllItemsOfCollection:(MHCollection *)collection
                                     completionBlock:(MHAPICompletionBlock)completionBlock
{
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"GET"
                                                           URLString:[NSString stringWithFormat:@"%@%@/items/",[self urlWithPath:@"collections"],collection.objId]
                                                          parameters:nil
                                                               error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          NSArray *responseArray = responseObject;
                                                                          completionBlock(responseArray, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark update item

- (AFHTTPRequestOperation *)updateItem:(MHItem *)item
                       completionBlock:(MHAPICompletionBlock)completionBlock
{
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableArray* mediaIds = [[NSMutableArray alloc] init];
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:@{@"name": item.objName,
                                                                                  @"collection": item.collection.objId}];
    if ([item.media count] > 0) {
        for (MHMedia* media in item.media) {
            if (media.objId) {
                [mediaIds addObject:media.objId];
            }
        }
        params[@"media"] = mediaIds;
    }
    
    if ([item.tags count]) {
        NSMutableArray* tags = [NSMutableArray new];
        for (MHTag* tag in item.tags) {
            [tags addObject:tag.tag];
        }
        params[@"tags"] = tags;
    }
    
    if (item.objDescription) {
        params[@"description"] = item.objDescription;
    }
    
    CLLocation *l = item.objLocation;
    if (l) {
        params[@"location"] = @{@"lat": @(l.coordinate.latitude),
                                @"lng": @(l.coordinate.longitude)};
    }
    
    __block MHItem* i = item;
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"PUT"
                                                           URLString:[NSString stringWithFormat:@"%@%@/",[self urlWithPath:@"items"],item.objId]
                                                          parameters:params
                                                               error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          i.objId = responseObject[@"id"];
                                                                          i.objName = responseObject[@"name"];
                                                                          i.objDescription = responseObject[@"description"];
                                                                          i.objCreatedDate = [MHItem createdDateFromString:responseObject[@"created_date"]];
                                                                          i.objOwner = responseObject[@"owner"];
                                                                          [i locationParser:responseObject[@"location"]];
                                                                          [i modifiedDateFromString:responseObject[@"modified_date"]];
                                                                          i.objStatus = objectStatusOk;
                                                                          [[MHCoreDataContext getInstance] saveContext];
                                                                          completionBlock(i, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark delete item

- (AFHTTPRequestOperation *)deleteItemWithId:(MHItem *)item
                             completionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"DELETE"
                                                        URLString:[NSString stringWithFormat:@"%@%@/",[self urlWithPath:@"items"],item.objId]
                                                       parameters:nil
                                                            error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          completionBlock(item, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          [self localizedDescriptionForErrorCode:error];
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (void)localizedDescriptionForErrorCode:(NSError *)error {
    
    NSString *domain = @"com.blstream.MyHoard";
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    switch ([error code]) {
        case 401:
            [userInfo setValue:@"Bad credentials" forKey:NSLocalizedDescriptionKey];
            error = [[NSError alloc]initWithDomain:domain code:401 userInfo:userInfo];
            break;
        case 403:
            [userInfo setValue:@"Forbidden" forKey:NSLocalizedDescriptionKey];
            error = [[NSError alloc]initWithDomain:domain code:403 userInfo:userInfo];
            break;
        case 400:
            [userInfo setValue:@"Validation error" forKey:NSLocalizedDescriptionKey];
            error = [[NSError alloc]initWithDomain:domain code:400 userInfo:userInfo];
            break;
        case 404:
            [userInfo setValue:@"Resource not found" forKey:NSLocalizedDescriptionKey];
            error = [[NSError alloc]initWithDomain:domain code:404 userInfo:userInfo];
            break;
        case 500:
            [userInfo setValue:@"Internal server error" forKey:NSLocalizedDescriptionKey];
            error = [[NSError alloc]initWithDomain:domain code:500 userInfo:userInfo];
            break;
    }
}

@end
