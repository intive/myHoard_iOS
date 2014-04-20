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
#import "MHItem.h"
#import "MHMedia.h"
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
                                                                          completionBlock(responseObject, nil);
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
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"POST"
                                                           URLString:[self urlWithPath:@"collections"]
                                                          parameters:@{@"name": collection.objName,
                                                                       @"description": collection.objDescription,
                                                                       @"tags":collection.objTags}
                                                               error:&error];
    
    __block MHCollection* c = collection;
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          
                                                                          NSString* date = responseObject[@"created_date"];
                                                                          c.objCreatedDate = [date dateFromRFC3339String];
                                                                          date = responseObject[@"modified_date"];
                                                                          c.objModifiedDate = [date dateFromRFC3339String];
                                                                          c.objOwner = responseObject[@"owner"];
                                                                          c.objId = responseObject[@"id"];
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
                                                           URLString:[self urlWithPath:@"collections"]
                                                          parameters:nil
                                                               error:&error];
    
    __block NSArray *coreDataCollections = [MHDatabaseManager allCollections];
    __block NSPredicate *predicate;
    __block NSArray *predicationResult;
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          if ([coreDataCollections count] == 0) {
                                                                              for (NSDictionary *responseDictionary in responseObject) {
                                                                                  
                                                                                  NSString* date = responseDictionary[@"created_date"];
                                                                                  NSDate* created = [date dateFromRFC3339String];
                                                                                  date = responseDictionary[@"modified_date"];
                                                                                  NSDate* modified = [date dateFromRFC3339String];
                                                                                  
                                                                                  MHCollection *createdCollection = [MHDatabaseManager insertCollectionWithObjName:responseDictionary[@"name"]
                                                                                                                                                    objDescription:responseDictionary[@"description"]
                                                                                                                                                           objTags:responseDictionary[@"tags"]
                                                                                                                                                    objCreatedDate:created
                                                                                                                                                   objModifiedDate:modified
                                                                                                                                       objOwnerNilAddLogedUserCode:responseDictionary[@"owner"]];
                                                                                  
                                                                                  createdCollection.objId = responseDictionary[@"id"];
                                                                              }
                                                                              [[MHCoreDataContext getInstance] saveContext];
                                                                          }else {
                                                                              for (NSDictionary *responseDictionary in responseObject) {
                                                                                  predicate = [NSPredicate predicateWithFormat:@"objId == %@", responseDictionary[@"id"]];
                                                                                  predicationResult = [coreDataCollections filteredArrayUsingPredicate:predicate];
                                                                                  
                                                                                  NSString* date = responseDictionary[@"created_date"];
                                                                                  NSDate* created = [date dateFromRFC3339String];
                                                                                  date = responseDictionary[@"modified_date"];
                                                                                  NSDate* modified = [date dateFromRFC3339String];
                                                                                  
                                                                                  if ([predicationResult count] == 0) {
                                                                                      MHCollection *createdCollection = [MHDatabaseManager insertCollectionWithObjName:responseDictionary[@"name"]
                                                                                                                                                        objDescription:responseDictionary[@"description"]
                                                                                                                                                               objTags:responseDictionary[@"tags"]
                                                                                                                                                        objCreatedDate:created
                                                                                                                                                       objModifiedDate:modified
                                                                                                                                           objOwnerNilAddLogedUserCode:responseDictionary[@"owner"]];
                                                                                      
                                                                                      createdCollection.objId = responseDictionary[@"id"];
                                                                                      
                                                                                      [[MHCoreDataContext getInstance] saveContext];
                                                                                  }else {
                                                                                      predicate = [NSPredicate predicateWithFormat:@"objModifiedDate < %@", modified];
                                                                                      NSArray *collectionsPredicatedWithModifiedDate = [predicationResult filteredArrayUsingPredicate:predicate];
                                                                                      
                                                                                      if ([collectionsPredicatedWithModifiedDate count] > 0) {
                                                                                          for (MHCollection *result in collectionsPredicatedWithModifiedDate) {
                                                                                              
                                                                                              [[MHCoreDataContext getInstance].managedObjectContext deleteObject:result];
                                                                                              [[MHCoreDataContext getInstance] saveContext];
                                                                                              
                                                                                              NSString* date = responseDictionary[@"created_date"];
                                                                                              NSDate* created = [date dateFromRFC3339String];
                                                                                              date = responseDictionary[@"modified_date"];
                                                                                              NSDate* modified = [date dateFromRFC3339String];
                                                                                              
                                                                                              MHCollection *createdCollection = [MHDatabaseManager insertCollectionWithObjName:responseDictionary[@"name"]
                                                                                                                                                                objDescription:responseDictionary[@"description"]
                                                                                                                                                                       objTags:responseDictionary[@"tags"]
                                                                                                                                                                objCreatedDate:created
                                                                                                                                                               objModifiedDate:modified
                                                                                                                                                   objOwnerNilAddLogedUserCode:responseDictionary[@"owner"]];
                                                                                              
                                                                                              createdCollection.objId = responseDictionary[@"id"];
                                                                                              
                                                                                              [[MHCoreDataContext getInstance] saveContext];
                                                                                          }
                                                                                      }else {
                                                                                          
                                                                                          predicate = [NSPredicate predicateWithFormat:@"objModifiedDate > %@", modified];
                                                                                          NSArray *collectionsPredicatedWithModifiedDate = [predicationResult filteredArrayUsingPredicate:predicate];
                                                                                          
                                                                                          if ([predicationResult count] > 0) {
                                                                                              for (MHCollection *result in collectionsPredicatedWithModifiedDate) {
                                                                                                  [[MHAPI getInstance]updateCollection:result completionBlock:^(id object, NSError *error)   {
                                                                                                      if (error) {
                                                                                                          UIAlertView *alert = [[UIAlertView alloc]
                                                                                                                                initWithTitle:@"Error"
                                                                                                                                message:error.localizedDescription
                                                                                                                                delegate:nil
                                                                                                                                cancelButtonTitle:@"OK"
                                                                                                                                otherButtonTitles:nil];
                                                                                                          
                                                                                                          [alert show];
                                                                                                      }
                                                                                                  }];
                                                                                              }
                                                                                          }
                                                                                      }
                                                                                  }
                                                                                  [[MHCoreDataContext getInstance] saveContext];
                                                                              }
                                                                          }
                                                                          
                                                                          [[MHCoreDataContext getInstance] saveContext];
                                                                          completionBlock(nil, nil);
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
                                                                          c.objName = responseObject[@"name"];
                                                                          c.objDescription = responseObject[@"description"];
                                                                          c.objTags = responseObject[@"tags"];
                                                                          NSString* date = responseObject[@"created_date"];
                                                                          c.objCreatedDate = [date dateFromRFC3339String];
                                                                          date = responseObject[@"modified_date"];
                                                                          c.objModifiedDate = [date dateFromRFC3339String];
                                                                          c.objOwner = responseObject[@"owner"];
                                                                          c.objId = responseObject[@"id"];
                                                                          
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

#pragma mark update collection

- (AFHTTPRequestOperation *)updateCollection:(MHCollection *)collection
                       completionBlock:(MHAPICompletionBlock)completionBlock {
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"PUT"
                                                        URLString:[NSString stringWithFormat:@"%@%@",[self urlWithPath:@"collections"],collection.objId]
                                                       parameters:@{@"name": collection.objName,
                                                                    @"description": collection.objDescription,
                                                                    @"tags":collection.objTags}
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

#pragma mark delete collection

- (AFHTTPRequestOperation *)deleteCollection:(MHCollection *)collection
                                   completionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"DELETE"
                                                        URLString:[NSString stringWithFormat:@"%@%@",[self urlWithPath:@"collections"],collection.objId]
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

#pragma mark Media/create media

- (AFHTTPRequestOperation *)createMedia:(MHMedia *)media
                        completionBlock:(MHAPICompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    __block MHMedia* m = media;

    NSData* assetData = [[MHImageCache sharedInstance] dataForKey:media.objKey];

    [manager POST:[self urlWithPath:@"media"] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:assetData name:@"image" fileName:m.objKey mimeType:@"image/*"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        m.objId = responseObject[@"id"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
    
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];

    return nil;
}

#pragma mark read media

- (AFHTTPRequestOperation *)readMedia:(MHMedia *)media
                            completionBlock:(MHAPICompletionBlock)completionBlock {
    
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
                                                                          NSData* imageData = responseObject;
                                                                          UIImage *responseImage = [UIImage imageWithData:imageData];
                                                                          [[MHImageCache sharedInstance] cacheImage:responseImage forKey:responseObject[@"id"]];
                                                                          tmpMedia.objKey = responseObject[@"id"];
                                                                          
                                                                          [self updateMedia:tmpMedia completionBlock:nil];
                                                                          
                                                                          completionBlock(nil, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark update media

- (AFHTTPRequestOperation *)updateMedia:(MHMedia *)media
                        completionBlock:(MHAPICompletionBlock)completionBlock {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];

    NSData* assetData = [[MHImageCache sharedInstance] dataForKey:media.objKey];
    [manager POST:[NSString stringWithFormat:@"%@%@/",[self urlWithPath:@"media"],media.objId] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:assetData name:@"image" fileName:media.objKey mimeType:@"image/*"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(nil, nil);
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
                                                                          [[MHCoreDataContext getInstance].managedObjectContext deleteObject:media];
                                                                          [[MHCoreDataContext getInstance]saveContext];
                                                                          completionBlock(nil, nil);
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
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    
    if ([item.media count] > 0) {
        for (MHMedia* media in item.media) {
            if (!media.objId) {
                params = [NSMutableDictionary dictionaryWithDictionary:@{@"name": item.objName,
                                                                         @"description": item.objDescription,
                                                                         @"collection": item.collection.objId}];
                
            }else {
                [mediaIds addObject:media.objId];
            }
        }
        params = [NSMutableDictionary dictionaryWithDictionary:@{@"name": item.objName,
                                                                 @"description": item.objDescription,
                                                                 @"media": mediaIds,
                                                                 @"collection": item.collection.objId}];
    }else {
        
        params = [NSMutableDictionary dictionaryWithDictionary:@{@"name": item.objName,
                                                                 @"description": item.objDescription,
                                                                 @"collection": item.collection.objId}];
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
                                                                          i.objLocation = responseObject[@"location"];
                                                                          NSString* date = responseObject[@"created_date"];
                                                                          i.objCreatedDate = [date dateFromRFC3339String];
                                                                          date = responseObject[@"modified_date"];
                                                                          i.objModifiedDate = [date dateFromRFC3339String];
                                                                          i.objOwner = responseObject[@"owner"];
                                                                          
                                                                          [[MHCoreDataContext getInstance] saveContext];
                                                                          completionBlock(i, error);
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
                                                                          for (NSDictionary *responseDictionary in responseObject) {
                                                                              
                                                                              NSString* date = responseDictionary[@"created_date"];
                                                                              NSDate* created = [date dateFromRFC3339String];
                                                                              date = responseDictionary[@"modified_date"];
                                                                              NSDate* modified = [date dateFromRFC3339String];
                                                                              
                                                                              CLLocation *l = [[CLLocation alloc]initWithLatitude:[responseDictionary[@"location"][@"lat"] doubleValue]longitude:[responseDictionary[@"location"][@"lng"]doubleValue]];
                                                                              
                                                                              MHItem *i = [MHDatabaseManager insertItemWithObjName:responseDictionary[@"name"] objDescription:responseDictionary[@"description"] objTags:nil objLocation:l objCreatedDate:created objModifiedDate:modified collection:collection];

                                                                              for (NSDictionary *d in responseDictionary[@"media"]) {
                                                                                  MHMedia *m = [MHDatabaseManager insertMediaWithCreatedDate:[NSDate date] objKey:nil item:i];
                                                                                  m.objId = d[@"id"];
                                                                                  [self readMedia:m completionBlock:^(id object, NSError *error) {
                                                                                      if (error) {
                                                                                          NSLog(@"There's been a problem while downloading your assets: %@", error);
                                                                                      }
                                                                                  }];
                                                                              }
                                                                              
                                                                              [[MHCoreDataContext getInstance] saveContext];
                                                                              completionBlock(i, error);
                                                                          }
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
    for (MHMedia* media in item.media) {
        [mediaIds addObject:media.objId];
    }
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:@{@"name": item.objName,
                                                                                  @"description": item.objDescription,
                                                                                  @"media": mediaIds,
                                                                                  @"collection": item.collection.objId}];
    
    CLLocation *l = item.objLocation;
    if (l) {
        params[@"location"] = @{@"lat": @(l.coordinate.latitude),
                                @"lng": @(l.coordinate.longitude)};
    }

    __block MHItem* i = item;
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"PUT"
                                                           URLString:[NSString stringWithFormat:@"%@%@",[self urlWithPath:@"items"],item.objId]
                                                          parameters:params
                                                               error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          completionBlock(i, error);
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
                                                        URLString:[NSString stringWithFormat:@"%@%@",[self urlWithPath:@"items"],item.objId]
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
